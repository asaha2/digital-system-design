-- this circuit converts Earth's time and date to Mars' time of day
-- 
-- entity name: g20_UTC_to_MTC
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

library lpm;
use lpm.lpm_components.all;

entity g20_UTC_to_MTC is
	port (
		clk			: in std_logic; -- 50 MHz clock
		rst			: in std_logic; -- ACTIVE LOW!
		
		earth_year	: in std_logic_vector(11 downto 0);
		earth_month	: in std_logic_vector(3 downto 0);
		earth_day	: in std_logic_vector(4 downto 0);
		
		earth_hour	: in std_logic_vector(4 downto 0);
		earth_min	: in std_logic_vector(5 downto 0);
		earth_sec	: in std_logic_vector(5 downto 0);
		
		mars_hour	: out std_logic_vector(4 downto 0);
		mars_min	: out std_logic_vector(5 downto 0);
		mars_sec	: out std_logic_vector(5 downto 0);
		
		done		: out std_logic -- asserted when output is valid
	);
end g20_UTC_to_MTC;

architecture rtl of g20_UTC_to_MTC is
	
	component g20_HMS_Counter is
		port (
			clock			: in std_logic;
			reset 			: in std_logic;
			sec_clock		: in std_logic;
			count_enable 	: in std_logic;
			load_enable		: in std_logic;
			H_Set			: in std_logic_vector(4 downto 0);
			M_Set			: in std_logic_vector(5 downto 0);
			S_Set			: in std_logic_vector(5 downto 0);
			Hours			: out std_logic_vector(4 downto 0);
			Minutes			: out std_logic_vector(5 downto 0);
			Seconds			: out std_logic_vector(5 downto 0);
			end_of_day		: out std_logic
		);
	end component;
	
	component g20_YMD_counter
		port (
			clk				: in std_logic;
			rst				: in std_logic;
			day_count_en	: in std_logic;
			load_enable		: in std_logic;
			y_set			: in std_logic_vector(11 downto 0);
			m_set			: in std_logic_vector(3 downto 0);
			d_set			: in std_logic_vector(4 downto 0);
			years			: out std_logic_vector(11 downto 0);
			months			: out std_logic_vector(3 downto 0);
			days			: out std_logic_vector(4 downto 0)
		);
	end component;
	
	component g20_HMS_to_sec
		port (
			Hours		: in std_logic_vector(4 downto 0);
			Minutes		: in std_logic_vector(5 downto 0);
			Seconds		: in std_logic_vector(5 downto 0);
			DaySeconds	: out std_logic_vector(16 downto 0)
		);
	end component;
	
	component g20_Seconds_to_Days
		port (
			seconds			: in std_logic_vector(16 downto 0);
			day_fraction	: out std_logic_vector(39 downto 0)
		);
	end component;
	
	-- miscellaneous signals
	signal reset		: std_logic;
	signal eod			: std_logic;
	signal cout			: std_logic;
	
	-- enable signals
	signal count_en		: std_logic;
	signal load_en		: std_logic;
	signal output_en	: std_logic;
	
	-- signals corresponding to Hours, Minutes and Seconds
	signal hours		: std_logic_vector(4 downto 0);
	signal minutes		: std_logic_vector(5 downto 0);
	signal seconds		: std_logic_vector(5 downto 0);
	
	-- signals corresponding to Days, Months and Years
	signal years		: std_logic_vector(11 downto 0);
	signal months		: std_logic_vector(3 downto 0);
	signal days			: std_logic_vector(4 downto 0);
	
	-- temporary conversion variables
	signal day_seconds	: std_logic_vector(16 downto 0);
	signal day_frac		: std_logic_vector(39 downto 0);
	
	------------------------------------------------------------------------
	-- NDays is 20 bits because the maximum numebr of years is 4000 and
	-- starting from January 6 2000 means another 2000 years can be counted.
	-- Even with 366 days/year (worst case scenario), we have 732000 days.
	-- That can be represented using 20 bits.
	------------------------------------------------------------------------
	signal NDays		: std_logic_vector(19 downto 0);
	
	------------------------------------------------------------------------
	-- fixed point extravaganza. We are going to use 37 bits for JD2000 since
	-- NDays is 20 bits and we need at least 20 bits to correctly represent
	-- the integral part without any loss of precision. Furthermore, 17 bits
	-- are required to accurately represent the fraction of the day with a
	-- resolution of one second.
	------------------------------------------------------------------------
	signal jd_2000			: std_logic_vector(36 downto 0);
	
	-- the multiplication result will be 67 bits as 0.973244297 needs 30 bits
	-- for full precision.
	signal mult_result		: std_logic_vector(66 downto 0);
	
	------------------------------------------------------------------------
	-- the multiplication result will be downsampled to 17 bits for the
	-- fractional part and 20 bits for the integer part. 0.00072 can be
	-- represented using 17 bits with minimal loss of precision.
	------------------------------------------------------------------------
	signal sub_out			: std_logic_vector(36 downto 0);
	signal sub_result		: std_logic_vector(36 downto 0);
	
	------------------------------------------------------------------------
	-- 5 bits are needed for the integer part 
	-- (number of hours) and 17 for the fractional part.
	------------------------------------------------------------------------
	signal mtc				: std_logic_vector(21 downto 0);
	signal num_min			: std_logic_vector(22 downto 0);
	signal num_sec			: std_logic_vector(22 downto 0);
	
	-- intermediate output signals
	signal mars_hour_i		: std_logic_vector(4 downto 0);
	signal mars_min_i		: std_logic_vector(5 downto 0);
	signal mars_sec_i		: std_logic_vector(5 downto 0);
	
begin

	---------------------------------------------------------------------------
	-- HMS counter
	---------------------------------------------------------------------------
	hms_counter : g20_HMS_Counter
		port map (
			clock			=> clk,
			reset			=> rst,
			sec_clock		=> '1',
			count_enable	=> count_en,
			load_enable		=> '0',
			H_set			=> (others => '0'),
			M_set			=> (others => '0'),
			S_set			=> (others => '0'),
			Hours			=> hours,
			Minutes			=> minutes,
			Seconds			=> seconds,
			end_of_day		=> eod
		);
		
	---------------------------------------------------------------------------
	-- YMD counter
	---------------------------------------------------------------------------
	ymd_counter : g20_YMD_counter
		port map (
			clk				=> clk,
			rst				=> rst,
			day_count_en	=> eod and count_en,
			load_enable		=> load_en,
			y_set			=> "011111010000",
			m_set			=> "0001",
			d_set			=> "00110",
			years			=> years,
			months			=> months,
			days			=> days
		);
		
	---------------------------------------------------------------------------
	-- HMS to seconds
	---------------------------------------------------------------------------
	HMS_to_sec : g20_HMS_to_sec
		port map (
			Hours		=> hours,
			Minutes		=> minutes,
			Seconds		=> seconds,
			DaySeconds	=> day_seconds
		);

	---------------------------------------------------------------------------
	-- seconds to day fraction
	---------------------------------------------------------------------------
	sec_to_day : g20_Seconds_to_Days
		port map (
			seconds			=> day_seconds,
			day_fraction	=> day_frac
		);
		
	---------------------------------------------------------------------------
	-- NDays
	---------------------------------------------------------------------------
	num_days : process(clk, rst)
	begin
		if (rst = '1') then
			NDays <= (others => '0');
		elsif (rising_edge(clk)) then
			if (eod = '1') then
				NDays <= NDays + 1;
			end if;
		end if;
	end process num_days;
	
	---------------------------------------------------------------------------
	-- MTC
	---------------------------------------------------------------------------
	-- downsample day_frac from 40 bits to 17 bits and combine with NDays to
	-- get JD2000.
	-- the following is taken from the lab slide
	jd_2000 <= NDays & day_frac(39 downto 23);
	
	-- 0.973244297 is 1045013107 when using 30-bit fixed point with 30 fraction bits.
	mult0 : lpm_mult
	GENERIC MAP (
		lpm_hint			=> "MAXIMIZE_SPEED=5",
		lpm_representation	=> "UNSIGNED",
		lpm_type			=> "LPM_MULT",
		lpm_widtha			=> 37,
		lpm_widthb		 	=> 30,
		lpm_widthp			=> 67
	)
	PORT MAP (
		dataa				=> jd_2000,
		datab				=> "111110010010011010001001110011",
		result 				=> mult_result
	);
	
	-- downsample the result of the multiplication to 37 bits and perform the
	-- subtraction. 0.00072 is 94 when using 37-bit fixed point with 17 fraction bits.
	sub0 : lpm_add_sub
	GENERIC MAP (
		lpm_direction		=> "SUB",
		lpm_representation	=> "UNSIGNED",
		lpm_width			=> 37
	)
	PORT MAP (
		dataa				=> mult_result(66 downto 30),
		datab				=> '0' & x"00000005E",
		result				=> sub_out,
		cout				=> cout
	);
	
	-- Take 2's complement if the result is negative.
	sub_result <= (not sub_out) + ('0' & "0000000001") when cout = '0'
		else sub_out;
	
	-- multiply 24 by the fractional part of sub_result.
	mult1 : lpm_mult
	GENERIC MAP (
		lpm_hint			=> "MAXIMIZE_SPEED=5",
		lpm_representation	=> "UNSIGNED",
		lpm_type			=> "LPM_MULT",
		lpm_widtha			=> 17,
		lpm_widthb			=> 5,
		lpm_widthp			=> 22
	)
	PORT MAP (
		dataa				=> sub_result(16 downto 0),
		datab				=> "11000",
		result				=> mtc
	);
	
	---------------------------------------------------------------------------
	-- Mars time
	---------------------------------------------------------------------------
	-- integer part is number of hours
	mars_hour_i <= mtc(21 downto 17);
	
	-- multiply by 60 and extract integer part to get minutes.
	mult2 : lpm_mult
	GENERIC MAP (
		lpm_hint			=> "MAXIMIZE_SPEED=5",
		lpm_representation	=> "UNSIGNED",
		lpm_type			=> "LPM_MULT",
		lpm_widtha			=> 17,
		lpm_widthb			=> 6,
		lpm_widthp 			=> 23
	)
	PORT MAP (
		dataa				=> mtc(16 downto 0),
		datab 				=> "111100",
		result				=> num_min
	);
	
	mars_min_i <= num_min(22 downto 17);
	
	-- multiply by 60 and extract integer part to get seconds.
	mult3 : lpm_mult
	GENERIC MAP (
		lpm_hint			=> "MAXIMIZE_SPEED=5",
		lpm_representation	=> "UNSIGNED",
		lpm_type			=> "LPM_MULT",
		lpm_widtha			=> 17,
		lpm_widthb			=> 6,
		lpm_widthp			=> 23
	)
	PORT MAP (
		dataa				=> num_min(16 downto 0),
		datab 				=> "111100",
		result				=> num_sec
	);
	
	mars_sec_i <= num_sec(22 downto 17);
	
	latch_outputs : process(clk, rst)
	begin
		if (rst = '1') then
			mars_hour <= (others => '0');
			mars_min <= (others => '0');
			mars_sec <= (others => '0');
		elsif (rising_edge(clk)) then
			if (output_en = '1') then
				mars_hour <= mars_hour_i;
				mars_min <= mars_min_i;
				mars_sec <= mars_sec_i;
			end if;
		end if;
	end process latch_outputs;
	
	---------------------------------------------------------------------------
	-- misc
	---------------------------------------------------------------------------
	reset <= not rst;
	done <= output_en;
	---------------------------------------------------------------------------
end rtl;