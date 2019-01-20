------------------------------------------------------------------------
--
--        Copyright (C) 2018
--        All rights reserved
--
--        filename: biplexers
--
--        created by Tyl at 2019-01-12 23:24:46
--        modified by Tyl at 2019-01-13 00:05:16
--
------------------------------------------------------------------------
-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)
library ieee;
use ieee.std_logic_1164.all;

entity biplexers is
	port(
		clk, reset: in std_logic;
		vol_timely: in std_logic_vector(11 downto 0);
		freq_timely: in std_logic_vector(23 downto 0);
		data_timely: in std_logic_vector(9 downto 0);
		data_saved: in std_logic_vector(9 downto 0);
		sel: in std_logic;
		save_in: in std_logic;
		q: out std_logic_vector(9 downto 0);
		vol: out std_logic_vector(11 downto 0);
		freq: out std_logic_vector(23 downto 0)
	);
end biplexers;

architecture rtl of biplexers is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1);

	-- Register to hold the current state
	signal state   : state_type;

	signal vol_saved: std_logic_vector(11 downto 0);
	signal freq_saved: std_logic_vector(23 downto 0);
begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					if sel = '1' then
						state <= s1;
					else
						state <= s0;
					end if;
				when s1=>
					if sel = '0' then
						state <= s0;
					else
						state <= s1;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when s0 =>
				q <= data_timely;
				vol <= vol_timely;
				freq <= freq_timely;
			when s1 =>
				q <= data_saved;
				vol <= vol_saved;
				freq <= freq_saved;
		end case;
	end process;

	--储存电压频率
	process(clk)
	begin
		if save_in = '1' then
			vol_saved <= vol_timely;
			freq_saved <= freq_timely;
		end if;
	end process;
end rtl;

