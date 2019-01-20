------------------------------------------------------------------------
--
--        Copyright (C) 2018
--        All rights reserved
--
--        filename: trigger_sec
--
--        created by Tyl at 2019-01-06 15:16:43
--        modified by Tyl at 2019-01-10 17:15:30
--
------------------------------------------------------------------------
-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity trigger_sec is
	port(
		clk, reset: in std_logic;
		start: in std_logic;
		suspend: in std_logic;
		stop: in std_logic;
		FIFO_data: in std_logic_vector(9 downto 0);
		trigger_switch: in std_logic;
		--statetest: out std_logic_vector(1 downto 0);
		--pretest: out std_logic_vector(9 downto 0);
		--midtest: out std_logic_vector(9 downto 0);
		--retest: out std_logic_vector(9 downto 0);
		--countertest: out integer range 0 to 2;
		RAM_data: out std_logic_vector(9 downto 0);
		trigger_FIFOR: out std_logic;
		trigger_ready: out std_logic
	);
end trigger_sec;

architecture rtl of trigger_sec is
	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3, s4);

	-- Register to hold the current state
	signal state   : state_type;

	signal pre: std_logic_vector(9 downto 0);
	signal mid: std_logic_vector(9 downto 0);
	signal re: std_logic_vector(9 downto 0);
	signal counter: integer range 0 to 4;
	signal trigger_num: std_logic_vector(9 downto 0) := B"10_0000_0000";
begin
	--测试模块
	--statetest <= "00" when state = s0 else
	--	"01" when state = s1 else
	--	"10" when state = s2 else
	--	"11";
	--pretest <= pre;
	--midtest <= mid;
	--retest <= re;
	--countertest <= counter;
	
	--触发电平变换
	process(trigger_switch)
	begin
		if trigger_switch = '0' then
			trigger_num <= B"10_0000_0000";
		else
			trigger_num <= B"11_0000_0000";
		end if;
	end process;

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					counter <= 0;
					if start = '1' then
						trigger_FIFOR <= '1';
						state <= s1;
					else
						trigger_FIFOR <= '0';
						state <= s0;
					end if;
				when s1=>
					if suspend = '0' then
						pre <= FIFO_data;
						mid <= pre;
						re <= mid;
						counter <= counter + 1;
						--判断读了3个
						if counter = 3 then
							--判断触发
							if pre > trigger_num and re < trigger_num then
								state <= s3;
							else
								state <= s2;
							end if;
						else
							state <= s1;
						end if;
					end if;
				when s2=>
					if suspend = '0' then
						pre <= FIFO_data;
						mid <= pre;
						re <= mid;
						--判断触发
						if pre > trigger_num and re < trigger_num then
							state <= s3;
						else
							state <= s2;
						end if;
					else
						trigger_FIFOR <= '0';
						state <= s4;
					end if;
				when s3 =>
					if suspend = '0' then
						counter <= 0;
						pre <= FIFO_data;
						mid <= pre;
						re <= mid;
					end if;
					if stop = '1' then
						trigger_FIFOR <= '0';
						state <= s0;
					else
						trigger_FIFOR <= '1';
						state <= s3;
					end if;
				when s4 =>
					if start = '1' then
						trigger_FIFOR <= '1';
						state <= s2;
					else
						state <= s4;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when s0 =>
				RAM_data <= (others => '0');
				trigger_ready <= '0';
			when s1 =>
				RAM_data <= (others => '0');
				trigger_ready <= '0';
			when s2 =>
				RAM_data <= (others => '0');
				trigger_ready <= '0';
			when s3 =>
				RAM_data <= re;
				trigger_ready <= '1';
			when s4 =>
				null;
		end case;
	end process;

end rtl;
