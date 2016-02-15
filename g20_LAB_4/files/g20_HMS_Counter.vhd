-- this circuit counts up Hours, Minutes and Seconds for Earth
-- 
-- entity name: g20_HMS_Counter
-- 
-- Copyright (C) 2014 Aditya Saha- 260453165, 
-- 					  Shayan Ahmad- 260350431
-- Version 1.0
-- Author: Aditya Saha- aditya.saha@mail.mcgill.ca, 
-- 		   Shayan Ahmad- shayan.ahmad@mail.mcgill.ca
--
-- Date: March 14, 2014

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g20_HMS_Counter is 
	port (
		clock : in std_logic;
		reset : in std_logic;
		
		sec_clock : in std_logic;
		count_enable : in std_logic;
		load_enable : in std_logic;
		
		H_Set : in std_logic_vector(4 downto 0);
		M_Set : in std_logic_vector(5 downto 0);
		S_Set : in std_logic_vector(5 downto 0);
		
		Hours : out std_logic_vector(4 downto 0);
		Minutes : out std_logic_vector(5 downto 0);
		Seconds : out std_logic_vector(5 downto 0);
		
		end_of_day: out std_logic
	);
end g20_HMS_Counter;
	
architecture Behavior of g20_HMS_Counter is 
	
	signal second_counter_fdbck : std_logic;
	signal minute_counter_fdbck : std_logic;
	signal hour_counter_fdbck : std_logic;
	
	signal second_counter_out, minute_counter_out : std_logic_vector(5 downto 0);
	signal hour_counter_out : std_logic_vector(4 downto 0);
	
	signal second_data, minute_data : std_logic_vector(5 downto 0);
	signal hour_data : std_logic_vector(4 downto 0);

	begin		
	
	-------------------SECONDS COUNTER---------------			
	
	-- explicitly specify the par value (59) for the second counter after 
	-- which the counter will reset and start counting again from 0
	with second_counter_out & sec_clock select 
		second_counter_fdbck <= '1' when "1110111",
								'0' when others;
	
	-- specify the counter to load the value only when the load value is high						
	with load_enable select
		second_data <= S_Set when '1',
					   "000000" when '0';
								
	second_counter : lpm_counter 
	GENERIC MAP (
		lpm_width => 6,
		lpm_direction => "up"
	)
	PORT MAP (
		clock => clock,
		data => second_data,
		q => second_counter_out,
		
		-- specify when the the counter shall start counting; this happens when 
		-- both count_enable and the sec_clock (unit second pulse) is high
		cnt_en => count_enable and sec_clock,
		
		-- specify when the counter shall reset (ie- start counting again from 0); this  
		-- happens trivially when reset or load enable is high, or when the counter reaches 59
		sload => reset or load_enable or second_counter_fdbck
															
	);	
	
	Seconds <= second_counter_out;

	
	-------------------MINUTE COUNTER---------------							
	
	-- explicitly specify the par value (59) for the minute counter after 
	-- which the counter will reset and start counting again from 0; this happens when
	-- the minute and second clock looks like 59:59
	with minute_counter_out & second_counter_out & sec_clock select 
		minute_counter_fdbck <= '1' when "1110111110111",
								'0' when others;
	
	-- specify the counter to load the value only when the load value is high
	with load_enable select
		minute_data <= M_Set when '1',
					   "000000" when '0';
	
	minute_counter : lpm_counter 
	GENERIC MAP (
		lpm_width => 6,
		lpm_direction => "up"
	)
	PORT MAP (
		clock => clock,
		data => minute_data,
		q => minute_counter_out,
		
		-- specify when the the counter shall start counting; this happens when 
		-- both count_enable and is high and second clock has reached 59
		cnt_en => count_enable and second_counter_fdbck,
		
		-- specify when the counter shall reset (ie- start counting again from 0); this  
		-- happens trivially when reset or load enable is high, or when the counter reaches 59 
		-- ie overall minute and second clock looks like 59:59
		sload => reset or load_enable or minute_counter_fdbck
	);
	
	Minutes <= minute_counter_out;
	
	-------------------HOUR COUNTER---------------	
	
	-- explicitly specify the par value (23) for the hour counter after 
	-- which the counter will reset and start counting again from 0; this happens when
	-- the minute and second clock looks like 23:59:59								
	with hour_counter_out & minute_counter_out & second_counter_out & sec_clock select 
		hour_counter_fdbck <= '1' when "101111110111110111",
							  '0' when others;
	
	-- specify the counter to load the value only when the load value is high
	with load_enable select
		hour_data <= H_Set when '1',
					   "00000" when '0';
					   
	hour_counter : lpm_counter 
	GENERIC MAP (
		lpm_width => 5,
		lpm_direction => "up"
	)
	PORT MAP (
		clock => clock,
		data => hour_data,
		q => hour_counter_out,
		
		-- specify when the the counter shall start counting; this happens when 
		-- both count_enable and is high and minute clock has reached 59
		cnt_en => count_enable and minute_counter_fdbck,
		
		-- specify when the counter shall reset (ie- start counting again from 0); this  
		-- happens trivially when reset or load enable is high, or when the counter reaches 23 
		-- ie overall hour, minute and second clock looks like 23:59:59
		sload => reset or load_enable or hour_counter_fdbck
	);
	Hours <= hour_counter_out;
	
	-------------------END OF DAY COUNTER---------------	
	
	-- set end_of_day high when overall hour, minute and second clock reaches 00:00:00 
	with hour_counter_out & minute_counter_out & second_counter_out & sec_clock select 
--		end_of_day <= '1' when "000000000000000001",
--					  '0' when others;
		end_of_day <= '1' when "101111110111110111",
					   '0' when others;
		
		
end Behavior;