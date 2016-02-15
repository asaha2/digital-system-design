-- this circuit is generated for the purpose of testing the previously made YMD Counter
-- circuit; it uses the 7 Segment Decoder code from the previous lab for display of
-- the sets of counters in the Altera board, the circuit also implements a custom package
-- that contains a function for conversio of binary to BCD.
-- 
-- entity name: g20_YMD_testbed
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

library work;
use work.mypackage.all; -- import auxiliary package made for conversion of binary to BCD

entity g20_YMD_testbed is
	port (
		clk			: in std_logic;	-- 50 MHz clock
		rst			: in std_logic;	-- ACTIVE LOW
		load_enable	: in std_logic;	-- ACTIVE LOW
		
		-- switching configuration for display:
		-- 00 is DD, 01 MM and 10 is YYYY
		display_sel	: in std_logic_vector(1 downto 0);
		
		-- day, month and year load values
		d_set		: in std_logic_vector(4 downto 0);
		m_set		: in std_logic_vector(3 downto 0);
		y_set		: in std_logic_vector(11 downto 0);
		
		-- LED display outputs
		hex0		: out std_logic_vector(6 downto 0);
		hex1		: out std_logic_vector(6 downto 0);
		hex2		: out std_logic_vector(6 downto 0);
		hex3		: out std_logic_vector(6 downto 0)
	);
end g20_YMD_testbed;

architecture structural of g20_YMD_testbed is

	component g20_Basic_Timer
		port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: in std_logic;
			EPULSE	: out std_logic;
			MPULSE	: out std_logic
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
	
	component g20_lab2_7_segment_decoder
		port (
			code			: in std_logic_vector(3 downto 0);
			RippleBlank_In	: in std_logic;
			RippleBlank_Out	: out std_logic;
			segments		: out std_logic_vector(6 downto 0)
		);
	end component;
	
	-- miscellaneous signals
	signal reset		: std_logic;
	signal load_en		: std_logic;
	signal day_count_en	: std_logic;
	
	-- time signals
	signal days			: std_logic_vector(4 downto 0);
	signal months		: std_logic_vector(3 downto 0);
	signal years		: std_logic_vector(11 downto 0);
	
	-- display signals
	signal display_bin	: std_logic_vector(11 downto 0);
	signal display_bcd	: std_logic_vector(15 downto 0);
	signal ripple		: std_logic_vector(3 downto 0);
	
begin
	-- unit day count pulse generator
	---------------------------------------------------------------------------
	pulse_gen : g20_Basic_Timer
		port map (
			clock	=> clk,
			reset	=> rst,
			enable	=> '1',
			EPULSE	=> day_count_en
		);
	---------------------------------------------------------------------------
	
	-- YMD counter module
	---------------------------------------------------------------------------
	YMD_counter : g20_YMD_counter
		port map (
			clk				=> clk,
			rst				=> rst,
			day_count_en	=> day_count_en,
			load_enable		=> load_en,
			y_set			=> y_set,
			m_set			=> m_set,
			d_set			=> d_set,
			years			=> years,
			months			=> months,
			days			=> days
		);
	---------------------------------------------------------------------------
	
	-- display
	---------------------------------------------------------------------------
	display_bin <= "0000000" & days when display_sel = "00" else -- fix bit resolution for days
				   "00000000" & months when display_sel = "01" else -- fix bit resolution for months
					years; -- use default bit resolution for years
					
	display_bcd <= binary_to_BCD(display_bin); -- conversion statement for binary to BCD
	
	ones : g20_lab2_7_segment_decoder
		port map (
			code			=> display_bcd(3 downto 0),
			RippleBlank_In	=> ripple(1),
			RippleBlank_Out	=> ripple(0),
			segments		=> hex0
		);
	
	tens : g20_lab2_7_segment_decoder
		port map (
			code			=> display_bcd(7 downto 4),
			RippleBlank_In	=> ripple(2),
			RippleBlank_Out	=> ripple(1),
			segments		=> hex1
		);
	
	hundreds : g20_lab2_7_segment_decoder
		port map (
			code			=> display_bcd(11 downto 8),
			RippleBlank_In	=> ripple(3),
			RippleBlank_Out	=> ripple(2),
			segments		=> hex2
		);
	
	thousands : g20_lab2_7_segment_decoder
		port map (
			code			=> display_bcd(15 downto 12),
			RippleBlank_In	=> not display_sel(1), -- blank for days and months but not for years
			RippleBlank_Out	=> ripple(3),
			segments		=> hex3
		);
	---------------------------------------------------------------------------
	
	-- reset 
	-- NOTE: reset and load_en are inverted considering they are connected 
	-- to the pushbuttons on the Altera board instead of slider switches.
	-- During previous labs, it has been noted that the default/rest position of
	-- the pushbuttons in Altera board implies inversion of the assigned signal
	---------------------------------------------------------------------------
	reset <= not rst;
	load_en <= not load_enable;
	---------------------------------------------------------------------------
end structural;