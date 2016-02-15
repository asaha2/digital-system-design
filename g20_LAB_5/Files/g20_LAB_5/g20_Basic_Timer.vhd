-- this circuit generates unit second pulses for earth and mars respectively
-- 
-- entity name: g20_Basic_Timer
--
-- Copyright (C) 2014 Aditya Saha, Shayan Ahmed
-- Version 1.0
-- Authors: Aditya Saha- aditya.saha@mail.mcgill.ca; Shayan Ahmed- shayan.ahmed@mail.mcgill.ca
-- Date: March 11th, 2014

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g20_Basic_Timer is 
	port( clock, reset, enable : in std_logic;
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

	earth_counter_fdbck <= '1' when (earth_counter_output = "00000000000000000000000000") else '0';		
	earth_counter_load <= reset or earth_counter_fdbck;	
	
	mars_counter_fdbck <= '1' when (mars_counter_output = "00000000000000000000000000") else '0';		
	mars_counter_load <= reset or mars_counter_fdbck;
	
	lpm_constant_mars : lpm_constant
	GENERIC MAP (
		lpm_cvalue => 51374562,
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "LPM_CONSTANT",
		lpm_width => 26
	)
	PORT MAP (
		result => mars_counter_constant
	);
	
	lpm_constant_earth : lpm_constant
	GENERIC MAP (
		lpm_cvalue => 49999999,
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "LPM_CONSTANT",
		lpm_width => 26
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
	