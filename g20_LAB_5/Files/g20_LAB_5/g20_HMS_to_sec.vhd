-- this circuit computes the number of seconds since midnight given
-- the current time in Hours (using a 24-hour rotation), Minutes and Seconds
-- 
-- entity name: g20_dayseconds
-- 
-- Copyright (C) 2014 Aditya Saha- 260453165, 
-- 					  Shayan Ahmad- 260350431
-- Version 1.0
-- Author: Aditya Saha- aditya.saha@mail.mcgill.ca, 
-- 		   Shayan Ahmad- shayan.ahmad@mail.mcgill.ca
--
-- Date: February 10, 2014

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g20_HMS_to_sec is
	port (
		Hours				: in std_logic_vector (4 downto 0);
		Minutes, Seconds	: in std_logic_vector (5 downto 0);
		DaySeconds			: out std_logic_vector (16 downto 0)
	);
end g20_HMS_to_sec;
	
architecture behaviour of g20_HMS_to_sec is	
	signal s3, s4: std_logic_vector (16 downto 0);
	signal s1, s2: std_logic_vector (10 downto 0);
	begin
	
	lpm_mult_component0 : lpm_mult
	GENERIC MAP (
		lpm_hint => "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 5,
		lpm_widthb => 6,
		lpm_widthp => 11
	)
	PORT MAP (
		dataa => Hours,
		datab => "111100",
		result => s1
	);	
	
	lpm_add_sub_component0 : lpm_add_sub
	GENERIC MAP (
		lpm_direction => "ADD",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 11
	)
	PORT MAP (
		dataa => s1,
		datab => "00000" & Minutes,
		result => s2
	);
	
	lpm_mult_component1 : lpm_mult
	GENERIC MAP (
		lpm_hint => "INPUT_B_IS_CONSTANT=YES,MAXIMIZE_SPEED=5",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 11,
		lpm_widthb => 6,
		lpm_widthp => 17
	)
	PORT MAP (
		dataa => s2,
		datab => "111100",
		result => s3
	);
	
	lpm_add_sub_component1 : lpm_add_sub
	GENERIC MAP (
		lpm_direction => "ADD",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 17
	)
	PORT MAP (
		dataa => s3,
		datab => "00000000000" & Seconds,
		result => s4
	);
	
	DaySeconds <= s4;

end behaviour;