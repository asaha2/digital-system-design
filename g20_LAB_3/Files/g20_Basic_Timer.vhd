-- this circuit acts as a frequency divider fed by the 50 MHz clock of the
-- Altera board, and outputs second pulse for Earth and Mars respectively
-- 
-- entity name: g20_Basic_Timer
-- 
-- Copyright (C) 2014 Aditya Saha- 260453165, 
-- 					  Shayan Ahmad- 260350431
-- Version 1.0
-- Author: Aditya Saha- aditya.saha@mail.mcgill.ca, 
-- 		   Shayan Ahmad- shayan.ahmad@mail.mcgill.ca
--
-- Date: March 14, 2014

-- IMPORTANT NOTE: THE CIRCUIT HAS BEEN TESTED WITH SMALLER CLOCK CYCLES TO SAVE UP ON TIME,
-- THE MODIFICATIONS MADE TO THE CODE HAVE BEEN COMMENTED OUT

-- IMPORTANT NOTE: THE RESET SIGNAL FED TO THE INPUT OR GATE HAS BEEN INVERTED FOR THE PURPOSE
-- OF TESTING ON THE ALTERA BOARD; THIS WAS BECAUSE WE WERE LOOKING TO ASSIGN RESET TO THE PUSH 
-- BUTTONS ON THE ALTERA BOARD. THE CODE MODIFICATIONS HAVE BEEN COMMENTED OUT

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g20_Basic_Timer is 
	port( clock : in std_logic;
		  reset : in std_logic;
		  enable : in std_logic;
		  EPULSE, MPULSE: out std_logic);
	end g20_Basic_Timer;
	
architecture Behavior of g20_Basic_Timer is 

	signal earth_counter_constant: std_logic_vector(25 downto 0);
	signal earth_counter_output: std_logic_vector(25 downto 0);
	signal earth_counter_load: std_logic;
	signal earth_counter_fdbck: std_logic;		

	signal mars_counter_constant: std_logic_vector(25 downto 0);
	signal mars_counter_output: std_logic_vector(25 downto 0);
	signal mars_counter_load: std_logic;
	signal mars_counter_fdbck: std_logic;	
	
	begin
	
	-- declare variable for the output signal that is fed back to the input OR gate
	-- explicitly such that the OR gate and the NOT gate following the output can be ignored
	earth_counter_fdbck <= '1' when (earth_counter_output = "00000000000000000000000000") else '0';		
--	earth_counter_load <= not (reset)or earth_counter_fdbck; --for on board testing purpose	
	earth_counter_load <= reset or earth_counter_fdbck;	
	
	mars_counter_fdbck <= '1' when (mars_counter_output = "00000000000000000000000000") else '0';		
--	mars_counter_load <= not (reset) or mars_counter_fdbck; --for on board testing purpose	
	mars_counter_load <= reset or mars_counter_fdbck;
	
	lpm_constant_mars : lpm_constant
	GENERIC MAP (
		lpm_cvalue => 51374562,
--		lpm_cvalue => 1026, --for simulation purpose
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "LPM_CONSTANT",
		lpm_width => 26
--		lpm_width => 11 --for simulation purpose
	)
	PORT MAP (
		result => mars_counter_constant
	);
	
	lpm_constant_earth : lpm_constant
	GENERIC MAP (
		lpm_cvalue => 49999999,
--		lpm_cvalue => 999, --for simulation purpose
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "LPM_CONSTANT",
		lpm_width => 26
--		lpm_width => 10 --for simulation purpose
	)
	PORT MAP (
		result => earth_counter_constant
	);

	lpm_counter_earth : lpm_counter
	GENERIC MAP (
		lpm_direction => "DOWN",
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 26
--		lpm_width => 10 --for simulation purpose
	) 
	PORT MAP (
		sload => earth_counter_load,
		clock => clock,
		data => earth_counter_constant,
		cnt_en => enable,
		q => earth_counter_output
	);
	
	lpm_counter_mars : lpm_counter
	GENERIC MAP (
		lpm_direction => "DOWN",
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 26
--		lpm_width => 11 --for simulation purpose
	)
	PORT MAP (
		sload => mars_counter_load,
		clock => clock,
		data => mars_counter_constant,
		cnt_en => enable,
		q => mars_counter_output
	);
	
	EPULSE <= earth_counter_fdbck;
	MPULSE <= mars_counter_fdbck;
	
end Behavior;
	