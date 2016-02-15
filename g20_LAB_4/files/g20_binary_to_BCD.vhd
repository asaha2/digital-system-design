-- this circuit converts a 6-bit binary number to a 2-digit BCD representation
--
-- entity name: g20_binary_to_BCD
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

entity g20_binary_to_BCD is
	port ( clock : in std_logic;
			bin : in unsigned (5 downto 0);
			BCD : out std_logic_vector (7 downto 0)
		);
end g20_binary_to_BCD;

architecture behavior of g20_binary_to_BCD is

BEGIN

	crc_table : lpm_rom 
	GENERIC MAP(
	lpm_widthad => 6, 
	lpm_numwords => 64,
	lpm_outdata => "UNREGISTERED",
	lpm_address_control => "REGISTERED", 
	lpm_file => "g20_lab2_q2.mif", 
	lpm_width => 8) 
	PORT MAP(inclock => clock, address => std_logic_vector (bin), q => BCD);	
	
end behavior;