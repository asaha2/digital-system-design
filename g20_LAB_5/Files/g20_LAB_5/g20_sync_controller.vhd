library ieee;
use ieee.std_logic_1164.all;

entity g20_sync_controller is
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
		years		: in std_logic_vector(11 downto 0);
		months		: in std_logic_vector(3 downto 0);
		days		: in std_logic_vector(4 downto 0);
		hours		: in std_logic_vector(4 downto 0);
		minutes		: in std_logic_vector(5 downto 0);
		seconds		: in std_logic_vector(5 downto 0);
		load_en		: out std_logic;
		count_en	: out std_logic;
		output_en	: out std_logic
	);
end g20_sync_controller;

architecture rtl of g20_sync_controller is
	
	type state_type is (idle, loading, counting, wait0, wait1, wait2, done);
	signal present_state	: state_type;
	signal next_state		: state_type;
	
begin
	
	---------------------------------------------------------------------------
	-- next state logic
	---------------------------------------------------------------------------
	state_comb : process(present_state, enable,
			years, months, days, hours, minutes, seconds,
			earth_year, earth_month, earth_day, earth_hour, earth_min, earth_sec)
	begin
		case present_state is
		when idle =>
			if (enable = '1') then
				next_state <= loading;
			else
				next_state <= idle;
			end if;
		when loading =>
			next_state <= counting;
		when counting =>
			if (years = earth_year and
				months = earth_month and
				days = earth_day and
				hours = earth_hour and
				minutes = earth_min and
				seconds = earth_sec) then
				next_state <= wait0;
			else
				next_state <= counting;
			end if;
		when wait0 =>
			next_state <= wait1;
		when wait1 =>
			next_state <= wait2;
		when wait2 =>
			next_state <= done;
		when done =>
			next_state <= idle;
		when others => -- this should never happen
			next_state <= idle;
		end case;
	end process state_comb;
	
	---------------------------------------------------------------------------	
	-- output logic
	---------------------------------------------------------------------------
	load_en <= '1' when present_state = loading
		else '0';
	
	count_en <= '1' when present_state = counting
		else '0';
	
	output_en <= '1' when present_state = done
		else '0';
		
	---------------------------------------------------------------------------	
	-- state update
	---------------------------------------------------------------------------
	state_update : process(clk, rst)
	begin
		if (rst = '1') then
			present_state <= idle;
		elsif (rising_edge(clk)) then
			present_state <= next_state;
		end if;
	end process state_update;
	---------------------------------------------------------------------------
end rtl;