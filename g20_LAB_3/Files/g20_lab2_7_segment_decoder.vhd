-- this circuit implements the 7-segment LED decoder
--
-- entity name: g20_7_segment_decoder
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

entity g20_lab2_7_segment_decoder is
	port ( code : in std_logic_vector (3 downto 0);
		RippleBlank_In : in std_logic;
		RippleBlank_Out : out std_logic;
		segments : out std_logic_vector (6 downto 0));
	end g20_lab2_7_segment_decoder;

architecture behavior of g20_lab2_7_segment_decoder is
	signal x: std_logic_vector(7 downto 0);

begin
	
with RippleBlank_In & code select

	x <= 
		--Ripple bit now 0
		--0
			"01000000" when "00000",
		--1	
			"01111001" when "00001",
		--2
			"00100100" when "00010",
		--3	
			"00110000" when "00011",
		--4	
			"00011001" when "00100",
		--5
			"00010010" when "00101",
		--6	
			"00000010" when "00110", 
		--7	
			"01111000" when "00111", 
		--8	
			"00000000" when "01000", 
		--9	
			"00010000" when "01001", 
		--A	
			"00001000" when "01010", 
		--B	
			"00000011" when "01011", 
		--C	
			"01000110" when "01100", 
		--D	
			"00100001" when "01101", 
		--E	
			"00000110" when "01110", 
		--F	
			"00001110" when "01111", 
		
		--Ripple bit now 1
		--0	
			"11111111" when "10000", 
		--1	
			"01111001" when "10001", 
		--2	
			"00100100" when "10010", 
		--3	
			"00110000" when "10011", 
		--4	
			"00011001" when "10100", 
		--5	
			"00010010" when "10101", 
		--6	
			"00000010" when "10110", 
		--7	
			"01111000" when "10111", 
		--8	
			"00000000" when "11000", 
		--9	
			"00010000" when "11001", 
		--A	
			"00001000" when "11010", 
		--B	
			"00000011" when "11011", 
		--C	
			"01000110" when "11100", 
		--D	
			"00100001" when "11101", 
		--E	
			"00000110" when "11110", 
		--F	
			"00001110" when "11111"; 
						
	RippleBlank_Out <= x(7);
	segments <= x(6 downto 0);
	
end behavior;
