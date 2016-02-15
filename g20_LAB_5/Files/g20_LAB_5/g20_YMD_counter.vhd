-- this circuit counts up Years, Months and Days
-- 
-- entity name: g20_YMD_counter
-- 
-- Copyright (C) 2014 Aditya Saha- 260453165, 
-- 					  Shayan Ahmad- 260350431
-- Version 1.0
-- Author: Aditya Saha- aditya.saha@mail.mcgill.ca, 
-- 		   Shayan Ahmad- shayan.ahmad@mail.mcgill.ca
--
-- Date: March 25, 2014

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity g20_YMD_counter is
	port (
		clk				: in std_logic;	-- 50 MHz clock
		rst				: in std_logic;	-- active-high asynchronous reset
		day_count_en	: in std_logic;	-- enable signal for day count
		load_enable		: in std_logic;	-- enable signal for loading values
		y_set			: in std_logic_vector(11 downto 0);
		m_set			: in std_logic_vector(3 downto 0);
		d_set			: in std_logic_vector(4 downto 0);
		years			: out std_logic_vector(11 downto 0);
		months			: out std_logic_vector(3 downto 0);
		days			: out std_logic_vector(4 downto 0)
	);
end g20_YMD_counter;

architecture rtl of g20_YMD_counter is

	-- counters
	-- initialize the reset/lowest count of each variables
	signal day_count	: std_logic_vector(4 downto 0);
	signal month_count	: std_logic_vector(3 downto 0);
	signal year_count	: std_logic_vector(11 downto 0);
	
	-- temporary variables
	-- declare indicator variables for months with 30/31 days and leap year
	signal month_31		: std_logic;
	signal month_30		: std_logic;
	signal leap_year	: std_logic;
	
	-- reset signals
	-- declare assertion signals for reset of day, month and year
	signal day_rst		: std_logic;
	signal month_rst	: std_logic;
	signal year_rst		: std_logic;

begin

	-- combinational block for determining 31 days, 30 days, leap years and
	-- reset signals; this explicitly defines each of the cases and asserts
	-- the respective variables accordingly
	---------------------------------------------------------------------------
	month_31 <= '1' when
		month_count = "0001" or month_count = "0011" or
		month_count = "0101" or	month_count = "0111" or
		month_count = "1000" or month_count = "1010" or
		month_count = "1100"
		else '0';
	
	month_30 <= '1' when
		month_count = "0100" or month_count = "0110" or
		month_count = "1001" or month_count = "1011"
		else '0';
	
	-- leap years are perfectly divisible by four
	-- notable- last two bits of multiples of four are zeros
	leap_year <= '1' when
		year_count(1 downto 0) = "00"
		else '0';
	
	-- reset day count if and only if following cases apply:
	-- (the month has 31 days AND day count is 31) OR
	-- (the month has 30 days AND day count is 30) OR
	-- the month is February AND:
	-- ((it is not a leap year AND day count is 28) OR
	-- (it is a leap year and day count is 29))
	day_rst <= '1' when
		(month_31 = '1' and day_count = "11111") or
		(month_30 = '1' and day_count = "11110") or
		(month_count = "0010" and
		((leap_year = '0' and day_count = "11100") or
		(leap_year = '1' and day_count = "11101")))
		else '0';
	
	-- reset month count if it is the 31st day AND 12th month
	month_rst <= '1' when
		day_count = "11111" and month_count = "1100"
		else '0';
	
	-- reset year count if it is the 31st day, 12th month and 4000th year.
	year_rst <= '1' when
		month_rst = '1' and year_count = x"FA0"
		else '0';
		
	---------------------------------------------------------------------------	
	-- process block for the operation
	-- priority is given to the synchronous load.
	---------------------------------------------------------------------------
	counters : process(clk, rst)
	begin
		-- reset day, month and year count when reset signal is asserted
		if (rst = '1') then
			day_count <= "00001";
			month_count <= "0001";
			year_count <= (others => '0');
			
		-- change signal states during rising edge of the clock copy input values for 
		-- day, month and year to the corresponding output when load signal is asserted
		elsif (rising_edge(clk)) then
			if (load_enable = '1') then
				day_count <= d_set;
				month_count <= m_set;
				year_count <= y_set;
			
			-- increment day count when corresponding enable signal is
			-- asserted; reset the day count when one of the previously 
			-- stated cases match
			else
				if (day_count_en = '1') then
					day_count <= day_count + 1;
				end if;
				
				if (day_rst = '1') then
					day_count <= "00001";
				end if;
				
				-- if it is the last day of the month but not the last month,
				-- increment the month count; if it is the last month, reset
				-- the month count
				if (day_rst = '1' and month_rst = '0') then
					month_count <= month_count + 1;
				elsif (month_rst = '1') then
					month_count <= "0001";
				end if;
				
				-- if it is the last day and month of the year but not the last
				-- year (ie 4000th year), increment the year count; if it is the
				-- last year, reset the year count
				if (month_rst = '1' and year_rst = '0') then
					year_count <= year_count + 1;
				elsif (year_rst = '1') then
					year_count <= (others => '0');
				end if;
			end if;
		end if;
	end process counters;
	---------------------------------------------------------------------------
	
	-- outputs
	---------------------------------------------------------------------------
	days <= day_count;
	months <= month_count;
	years <= year_count;
	---------------------------------------------------------------------------
end rtl;