-- this circuit implements the BCD to 7-segment LED decoder
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

entity g20_BCD_to_7_segment is

	port ( 
	clock : in std_logic; 
	bin : in unsigned(5 downto 0);
	output : out std_logic_vector(27 downto 0));

end g20_BCD_to_7_segment;

architecture BEHAVIOR of g20_BCD_to_7_segment is

	component g20_lab2_7_segment_decoder 
		port ( 
		code : in std_logic_vector(3 downto 0); 
		RippleBlank_In : in std_logic; 
		RippleBlank_Out : out std_logic; 
		segments : out std_logic_vector(6 downto 0));
	end component;

	component g20_binary_to_BCD 
	port ( 
	clock : in std_logic; 
	bin : in unsigned(5 downto 0);
	BCD : out std_logic_vector(7 downto 0));

	end component;

	signal A1, A2, A3, A4, A5, A6, A7, A8 : std_logic;
	signal outputBCD : std_logic_vector (7 downto 0);

	begin 
	A1 <= '1';
	A4 <= '0';
	A6 <= '1';
	A5 <= '1';

	inst1: g20_binary_to_BCD PORT MAP (BCD => outputBCD, bin => bin, clock => clock);
	inst2: g20_lab2_7_segment_decoder PORT MAP (code => outputBCD(7 downto 4), RippleBlank_In => A1, RippleBlank_Out => A3, segments => output(13 downto 7));
	inst3: g20_lab2_7_segment_decoder PORT MAP (code => outputBCD(3 downto 0), RippleBlank_In => A2, RippleBlank_Out => A4, segments =>output(6 downto 0));
	inst4: g20_lab2_7_segment_decoder PORT MAP (code => "0000", RippleBlank_In => A5, RippleBlank_Out => A7, segments => output(27 downto 21));
	inst5: g20_lab2_7_segment_decoder PORT MAP (code => "0000", RippleBlank_In => A6, RippleBlank_Out => A8, segments => output(20 downto 14));


end BEHAVIOR;