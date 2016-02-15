-- this is an auxiliary package containing the method that 
-- converts a 12-bit binary number to a 16-bit BCD representation
--
-- package name: mypackage
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

-- package declaration
package mypackage is
	function binary_to_BCD (data_in : std_logic_vector(11 downto 0))
	return std_logic_vector;
end mypackage;

package body mypackage is

	function binary_to_BCD (data_in : std_logic_vector(11 downto 0))
	return std_logic_vector is
		variable i			: integer;
		variable ones		: std_logic_vector(3 downto 0);
		variable tens		: std_logic_vector(3 downto 0);
		variable hundreds	: std_logic_vector(3 downto 0);
		variable thousands	: std_logic_vector(3 downto 0);
	begin
		ones := "0000";
		tens := "0000";
		hundreds := "0000";
		thousands := "0000";
		for i in 11 downto 0 loop
			if (thousands >= "0101") then
				thousands := thousands + "0011";
			end if;
			
			if (hundreds >= "0101") then
				hundreds := hundreds + "0011";
			end if;
			
			if (tens >= "0101") then
				tens := tens + "0011";
			end if;
			
			if (ones >= "0101") then
				ones := ones + "0011";
			end if;
			
			thousands := thousands(2 downto 0) & hundreds(3);
			hundreds := hundreds(2 downto 0) & tens(3);
			tens := tens(2 downto 0) & ones(3);
			ones := ones(2 downto 0) & data_in(i);
		end loop;
		
		return thousands & hundreds & tens & ones;
	end binary_to_BCD;
end package body;