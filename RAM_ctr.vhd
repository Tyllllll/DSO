------------------------------------------------------------------------
--
--        Copyright (C) 2018
--        All rights reserved
--
--        filename: RAM_ctr
--
--        created by Tyl at 2019-01-06 08:57:33
--        modified by Tyl at 2019-01-13 00:35:01
--
------------------------------------------------------------------------
-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)
library ieee;
use ieee.std_logic_1164.all;

entity RAM_ctr is
	port(
		clk, reset: in std_logic;
		trigger_ready: in std_logic;
		RAMWCO: in std_logic;
		RAMRCO: in std_logic;
		save_in: in std_logic;
		pause: in std_logic;
		RAMWen: out std_logic;
		RAMRen: out std_logic;
		NRAMWen: out std_logic;
		NRAMRen: out std_logic;
		Flashen: out std_logic
	);
end RAM_ctr;

architecture rtl of RAM_ctr is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2);

	-- Register to hold the current state
	signal state   : state_type;

begin
	--测试模块
	--statetest <= O"0" when state = s0 else
	--	O"1" when state = s1 else
	--	O"2" when state = s2 else
	--	O"3";
	--save_flagtest <= save_flag;
	
	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				--准备状态，等待触发器发出ready信号
				when s0=>
					if trigger_ready = '1' then
						if save_in  = '1' then
							state <= s2;
						else
							state <= s1;
						end if;
					else
						state <= s0;
					end if;
				--RAM写入数据，没保存
				when s1=>
					if trigger_ready = '0' then
						state <= s0;
					elsif RAMWCO = '1' then
						state <= s0;
					else
						state <= s1;
					end if;
				--RAM写入数据，保存
				when s2=>
					if trigger_ready = '0' then
						state <= s0;
					elsif RAMWCO = '1' then
						state <= s0;
					else
						state <= s2;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when s0 =>
				RAMWen <= '0';
				NRAMWen <= '1';
				Flashen <= '0';
			when s1 =>
				if pause = '1' then
					RAMWen <= '0';
					NRAMWen <= '1';
				else
					RAMWen <= '1';
					NRAMWen <= '0';
				end if;
				Flashen <= '0';
			when s2 =>
				if pause = '1' then
					RAMWen <= '0';
					NRAMWen <= '1';
				else
					RAMWen <= '1';
					NRAMWen <= '0';
				end if;
				Flashen <= '1';
		end case;
	end process;
	
	--读使能
	RAMRen <= '1';
	NRAMRen <= '0';

end rtl;
