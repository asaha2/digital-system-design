-- Converts a time of day in seconds to a day fraction representation
--
-- entity name: g20_Seconds_to_Days
--
-- Copyright (C) 2014 Aditya Saha- 260453165, 
--					  Shayan Ahmad- 260350431
-- Version 1.0
-- Author: Aditya Saha- aditya.saha@mail.mcgill.ca,
--		   Shayan Ahmad- shayan.ahmad@mail.mcgill.ca
-- Date: 24th January 2014

library ieee; -- allows use of the std_loginc_vector type
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g20_Seconds_to_Days is
	port ( seconds	: in unsigned(16 downto 0);
	   day_fraction : out unsigned(39 downto 0) );
end g20_Seconds_to_Days;

architecture behavior1 of g20_Seconds_to_Days is
	signal adder1: unsigned(19 downto 0);
	signal adder2: unsigned(23 downto 0);
	signal adder3: unsigned(26 downto 0);
	signal adder4: unsigned(27 downto 0);
	signal adder5: unsigned(28 downto 0);
	signal adder6: unsigned(30 downto 0);
	signal adder7: unsigned(34 downto 0);
	signal adder8: unsigned(39 downto 0);
	signal adder9: unsigned(39 downto 0);

begin
	adder1 <= seconds +("0" & seconds & "00");
	adder2 <= adder1 + ("0" & seconds & "000000");
	adder3 <= adder2 + ("0" & seconds & "000000000");
	adder4 <= adder3 + ("0" & seconds & "0000000000");
	adder5 <= adder4 + ("0" & seconds & "00000000000");
	adder6 <= adder5 + ("0" & seconds & "0000000000000");
	adder7 <= adder6 + ("0" & seconds & "00000000000000000");
	adder8 <= adder7 + ("0" & seconds & "0000000000000000000000");
	adder9 <= adder8 + (seconds & "00000000000000000000000");
	day_fraction <= adder9;
end behavior1;


