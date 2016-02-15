-- this circuit implements the complete integrated mars clock circuit
--
-- entity name: g20_lab5
-- 
-- Copyright (C) 2014 Aditya Saha- 260453165, 
-- 					  Shayan Ahmad- 260350431
-- Version 1.0
-- Author: Aditya Saha- aditya.saha@mail.mcgill.ca, 
-- 		   Shayan Ahmad- shayan.ahmad@mail.mcgill.ca
--
-- Date: April 9, 2014

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.mypackage.all;

entity g20_lab5 is
	port (
		clk				: in std_logic;
		
		-- push buttons. Active LOW!
		rst				: in std_logic;
		perform			: in std_logic;
		
		-- switches
		switches		: in std_logic_vector(9 downto 0);
		
		-- LED
		dst_out			: out std_logic;
		
		-- 7-segment displays
		hex0			: out std_logic_vector(6 downto 0);
		hex1			: out std_logic_vector(6 downto 0);
		hex2			: out std_logic_vector(6 downto 0);
		hex3			: out std_logic_vector(6 downto 0)
	);
end g20_lab5;

architecture structural of g20_lab5 is
	
	---------------------------------------------------------------------------
	-- COMPONENT DECLARATIONS
	---------------------------------------------------------------------------
	component g20_Basic_Timer
		port (
			clock	: in std_logic;
			reset	: in std_logic;
			enable	: in std_logic;
			EPULSE	: out std_logic;
			MPULSE	: out std_logic
		);
	end component;
	
	component g20_HMS_Counter
		port (
			clock			: in std_logic;
			reset			: in std_logic;
			sec_clock		: in std_logic;
			count_enable	: in std_logic;
			load_enable		: in std_logic;
			H_Set 			: in std_logic_vector(4 downto 0);
			M_Set 			: in std_logic_vector(5 downto 0);
			S_Set 			: in std_logic_vector(5 downto 0);
			Hours 			: out std_logic_vector(4 downto 0);
			Minutes 		: out std_logic_vector(5 downto 0);
			Seconds 		: out std_logic_vector(5 downto 0);
			end_of_day		: out std_logic
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
	
	component g20_UTC_to_MTC
		port (
			clk			: in std_logic;
			rst			: in std_logic;
			enable		: in std_logic;
			earth_year	: in std_logic_vector(11 downto 0);
			earth_month	: in std_logic_vector(3 downto 0);
			earth_day	: in std_logic_vector(4 downto 0);
			earth_hour	: in std_logic_vector(4 downto 0);
			earth_min	: in std_logic_vector(5 downto 0);
			earth_sec	: in std_logic_vector(5 downto 0);
			mars_hour	: out std_logic_vector(4 downto 0);
			mars_min	: out std_logic_vector(5 downto 0);
			mars_sec	: out std_logic_vector(5 downto 0);
			done		: out std_logic
		);
	end component;
	
	component g20_controller
		port (
			clk					: in std_logic;
			rst					: in std_logic;
			switches			: in std_logic_vector(9 downto 0);
			perform				: in std_logic;
			sync_done			: in std_logic;
			sec_pulse_en		: out std_logic;
			earth_hms_count_en	: out std_logic;
			earth_hms_load_en	: out std_logic;
			earth_ymd_load_en	: out std_logic;
			mars_hms_count_en	: out std_logic;
			mars_hms_load_en	: out std_logic;
			sync_time_en		: out std_logic;
			sync_rst			: out std_logic;
			earth_year_out		: out std_logic_vector(11 downto 0);
			earth_month_out		: out std_logic_vector(3 downto 0);
			earth_day_out		: out std_logic_vector(4 downto 0);
			earth_hour_out		: out std_logic_vector(4 downto 0);
			earth_min_out		: out std_logic_vector(5 downto 0);
			earth_sec_out		: out std_logic_vector(5 downto 0);
			earth_dst_out		: out std_logic;
			earth_tz_out		: out std_logic_vector(4 downto 0);
			mars_tz_out			: out std_logic_vector(4 downto 0)
		);
	end component;
	
	component g20_7_segment_decoder
		port (
			code			: in std_logic_vector(3 downto 0);
			RippleBlank_In	: in std_logic;
			RippleBlank_Out	: out std_logic;
			segments		: out std_logic_vector(6 downto 0)
		);
	end component;
	
	-- reset
	signal reset				: std_logic;
	
	-- 000 -> display Earth time + DST
	-- 001 -> display Earth date
	-- 010 -> display Mars time
	-- 011 -> set Earth time zone
	-- 100 -> set Mars time zone
	-- 101 -> set Earth time and date
	-- 110 -> sync Earth and Mars times
	signal mode					: std_logic_vector(2 downto 0);
	
	-- 00 -> seconds or days
	-- 01 -> minutes or months
	-- 10 -> hours or years
	signal display_sel			: std_logic_vector(1 downto 0);
	
	-- DST
	signal dst					: std_logic;
	
	-- basic timer
	signal sec_pulse_en			: std_logic;
	signal earth_sec_pulse		: std_logic;
	signal mars_sec_pulse		: std_logic;
	
	-- Earth HMS
	signal earth_hms_count_en	: std_logic;
	signal earth_hms_load_en	: std_logic;
	signal earth_eod			: std_logic;
	signal earth_hours_in		: std_logic_vector(4 downto 0);
	signal earth_mins_in		: std_logic_vector(5 downto 0);
	signal earth_secs_in		: std_logic_vector(5 downto 0);
	signal earth_hours			: std_logic_vector(4 downto 0);
	signal earth_mins			: std_logic_vector(5 downto 0);
	signal earth_secs			: std_logic_vector(5 downto 0);
	
	-- Mars HMS
	signal mars_hms_count_en	: std_logic;
	signal mars_hms_load_en		: std_logic;
	signal mars_eod				: std_logic;
	signal mars_hours_in		: std_logic_vector(4 downto 0);
	signal mars_mins_in			: std_logic_vector(5 downto 0);
	signal mars_secs_in			: std_logic_vector(5 downto 0);
	signal mars_hours			: std_logic_vector(4 downto 0);
	signal mars_mins			: std_logic_vector(5 downto 0);
	signal mars_secs			: std_logic_vector(5 downto 0);
	
	-- Earth YMD
	signal earth_ymd_load_en	: std_logic;
	signal earth_years_in		: std_logic_vector(11 downto 0);
	signal earth_months_in		: std_logic_vector(3 downto 0);
	signal earth_days_in		: std_logic_vector(4 downto 0);
	signal earth_years			: std_logic_vector(11 downto 0);
	signal earth_months			: std_logic_vector(3 downto 0);
	signal earth_days			: std_logic_vector(4 downto 0);
	
	-- UTC to MTC
	signal sync_rst				: std_logic;
	signal sync_time_en			: std_logic;
	signal sync_done			: std_logic;
	signal mars_sync_hours		: std_logic_vector(4 downto 0);
	signal mars_sync_mins		: std_logic_vector(5 downto 0);
	signal mars_sync_secs		: std_logic_vector(5 downto 0);
	
	-- controller
	signal earth_tz				: std_logic_vector(4 downto 0);
	signal mars_tz				: std_logic_vector(4 downto 0);
	
	-- display
	signal display_bin			: std_logic_vector(11 downto 0);
	signal display_bcd			: std_logic_vector(15 downto 0);
	signal ripple				: std_logic_vector(3 downto 0);

begin
	
	---------------------------------------------------------------------------
	-- COMPONENT INITIALIZATIONS
	---------------------------------------------------------------------------
	
	---------------------------------------------------------------------------
	-- Earth and Mars second pulses
	---------------------------------------------------------------------------
	sec_pulse_gen : g20_Basic_Timer
		port map (
			clock	=> clk,
			reset	=> reset,
			enable	=> sec_pulse_en,
			EPULSE	=> earth_sec_pulse,
			MPULSE	=> mars_sec_pulse
		);
		
	---------------------------------------------------------------------------	
	-- Earth HMS
	---------------------------------------------------------------------------
	earth_hms_counter : g20_HMS_Counter
		port map (
			clock			=> clk,
			reset 			=> reset,
			sec_clock		=> earth_sec_pulse,
			count_enable	=> earth_hms_count_en,
			load_enable		=> earth_hms_load_en,
			H_Set			=> earth_hours_in,
			M_Set			=> earth_mins_in,
			S_Set			=> earth_secs_in,
			Hours			=> earth_hours,
			Minutes			=> earth_mins,
			Seconds			=> earth_secs,
			end_of_day		=> earth_eod
		);
		
	---------------------------------------------------------------------------	
	-- Mars HMS
	---------------------------------------------------------------------------
	mars_hms_counter : g20_HMS_Counter
		port map (
			clock			=> clk,
			reset 			=> reset,
			sec_clock		=> mars_sec_pulse,
			count_enable	=> mars_hms_count_en,
			load_enable		=> mars_hms_load_en,
			H_Set			=> mars_sync_hours,
			M_Set			=> mars_sync_mins,
			S_Set			=> mars_sync_secs,
			Hours			=> mars_hours,
			Minutes			=> mars_mins,
			Seconds			=> mars_secs,
			end_of_day		=> mars_eod
		);
		
	---------------------------------------------------------------------------	
	-- Earth YMD
	---------------------------------------------------------------------------
	earth_ymd_counter : g20_YMD_counter
		port map (
			clk				=> clk,
			rst				=> reset,
			day_count_en	=> earth_eod,
			load_enable		=> earth_ymd_load_en,
			y_set			=> earth_years_in,
			m_set			=> earth_months_in,
			d_set			=> earth_days_in,
			years			=> earth_years,
			months			=> earth_months,
			days			=> earth_days
		);
		
	---------------------------------------------------------------------------	
	-- UTC to MTC stuff
	---------------------------------------------------------------------------
	utc_to_mtc : g20_UTC_to_MTC
		port map (
			clk			=> clk,
			rst			=> sync_rst,
			enable		=> sync_time_en,
			earth_year	=> earth_years,
			earth_month	=> earth_months,
			earth_day	=> earth_days,
			earth_hour	=> earth_hours,
			earth_min	=> earth_mins,
			earth_sec	=> earth_secs,
			mars_hour	=> mars_sync_hours,
			mars_min	=> mars_sync_mins,
			mars_sec	=> mars_sync_secs,
			done		=> sync_done
		);
		
	---------------------------------------------------------------------------	
	-- master controller
	---------------------------------------------------------------------------
	main_controller : g20_controller
		port map (
			clk					=> clk,
			rst					=> reset,
			switches			=> switches,
			perform				=> perform,
			sync_done			=> sync_done,
			sec_pulse_en		=> sec_pulse_en,
			earth_hms_count_en	=> earth_hms_count_en,
			earth_hms_load_en	=> earth_hms_load_en,
			earth_ymd_load_en	=> earth_ymd_load_en,
			mars_hms_count_en	=> mars_hms_count_en,
			mars_hms_load_en	=> mars_hms_load_en,
			sync_time_en		=> sync_time_en,
			sync_rst			=> sync_rst,
			earth_year_out		=> earth_years_in,
			earth_month_out		=> earth_months_in,
			earth_day_out		=> earth_days_in,
			earth_hour_out		=> earth_hours_in,
			earth_min_out		=> earth_mins_in,
			earth_sec_out		=> earth_secs_in,
			earth_dst_out		=> dst,
			earth_tz_out		=> earth_tz,
			mars_tz_out			=> mars_tz
		);
		
	---------------------------------------------------------------------------	
	-- display
	---------------------------------------------------------------------------
	display_select : process(mode, display_sel, dst,
			earth_years, earth_months, earth_days,
			earth_hours, earth_mins, earth_secs,
			mars_hours, mars_mins, mars_secs,
			earth_tz, mars_tz)
	begin
		case mode is
		when "000" => -- Earth time + DST
			case display_sel is
			when "00" => -- seconds
				display_bin <= "000000" & earth_secs;
			when "01" => -- minutes
				display_bin <= "000000" & earth_mins;
			when "10" => -- hours
				display_bin <= "0000000" & earth_hours;
			when others => -- time zone
				display_bin <= "0000000" & earth_tz;
			end case;
			dst_out <= dst;
		when "001" => -- Earth date
			case display_sel is
			when "00" => -- days
				display_bin <= "0000000" & earth_days;
			when "01" => -- months
				display_bin <= "00000000" & earth_months;
			when others => -- years
				display_bin <= earth_years;
			end case;
			dst_out <= '0';
		when "010" => -- Mars time
			case display_sel is
			when "00" => -- seconds
				display_bin <= "000000" & mars_secs;
			when "01" => -- minutes
				display_bin <= "000000" & mars_mins;
			when "10" => -- hours
				display_bin <= "0000000" & mars_hours;
			when others => -- time zone
				display_bin <= "0000000" & mars_tz;
			end case;
			dst_out <= '0';
		when others =>
			display_bin <= (others => '0');
			dst_out <= '0';
		end case;
	end process display_select;
	
	display_bcd <= binary_to_BCD(display_bin);
	
	ones : g20_7_segment_decoder
		port map (
			code			=> display_bcd(3 downto 0),
			RippleBlank_In	=> ripple(1),
			RippleBlank_Out	=> ripple(0),
			segments		=> hex0
		);
	
	tens : g20_7_segment_decoder
		port map (
			code			=> display_bcd(7 downto 4),
			RippleBlank_In	=> ripple(2),
			RippleBlank_Out	=> ripple(1),
			segments		=> hex1
		);
	
	hundreds : g20_7_segment_decoder
		port map (
			code			=> display_bcd(11 downto 8),
			RippleBlank_In	=> ripple(3),
			RippleBlank_Out	=> ripple(2),
			segments		=> hex2
		);
	
	thousands : g20_7_segment_decoder
		port map (
			code			=> display_bcd(15 downto 12),
			RippleBlank_In	=> '0', --not display_sel(1), -- (mode /= "010" and display_sel(1) = '0'), -- blank for everthing except years
			RippleBlank_Out	=> ripple(3),
			segments		=> hex3
		);
		
	---------------------------------------------------------------------------	
	-- misc
	---------------------------------------------------------------------------
	reset <= not rst;
	mode <= switches(2 downto 0);
	display_sel <= switches(4 downto 3);
	---------------------------------------------------------------------------
	
end structural;