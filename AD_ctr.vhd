------------------------------------------------------------------------
--
--        Copyright (C) 2018
--        All rights reserved
--
--        filename: AD_ctr
--
--        created by Tyl at 2019-01-07 17:14:48
--        modified by Tyl at 2019-01-11 11:57:36
--
------------------------------------------------------------------------
-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity AD_ctr is
	port(
		clk, reset: in std_logic;
		ADC_DOUT: in std_logic;
		hscan_switch: in std_logic;
		ADC_CONVS: out std_logic;
		ADC_DIN: out std_logic;
		ADC_SCLK: out std_logic;
		q: out std_logic_vector(9 downto 0)
		--datatest: out std_logic_vector(0 to 11);
		--countertest: out std_logic_vector(0 to 6);
		--statetest: out std_logic_vector(2 downto 0);
		--myin: in std_logic_vector(0 to 5);
		--loopnumtest: out std_logic_vector(0 to 7)
	);
end AD_ctr;

architecture rtl of AD_ctr is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3, s4, s5, s6);

	-- Register to hold the current state
	signal state   : state_type;
	
	signal isInit: std_logic := '0';
	signal counter: std_logic_vector(0 to 6);
	signal InitData: std_logic_vector(0 to 5) := "111111";
	signal data: std_logic_vector(0 to 9);
	--计数周期，周期越大采样频率越低，周期最小为X"4F"，即80个周期。
	constant fullNum: std_logic_vector(7 downto 0) := X"4F";
	signal loopnum: std_logic_vector(0 to 7);
	
begin	
	--测试模块
	--datatest <= data;
	--countertest <= counter;
	--statetest <= O"0" when state = s0 else
	--	O"1" when state = s1 else
	--	O"2" when state = s2 else
	--	O"3" when state = s3 else
	--	O"4" when state = s4 else
	--	O"5";
	--loopnumtest <= loopnum;
		
	--可重配置InitData
	--InitData <= myin;
	
	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '1' then
			state <= s0;
			isInit <= '0';
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					state <= s1;
				when s1=>
					--延迟64个时钟周期
					if counter = X"3F" then
						if isInit = '0' then
							state <= s2;
						else
							state <= s4;
						end if;
					else
						state <= s1;
					end if;
				when s2=>
					--进行6个时钟周期的初始化，计数到十进制69
					if counter = X"45" then
						state <= s3;
					else
						state <= s2;
					end if;
				when s3 =>
					--延迟10个时钟周期，到fullNum
					if counter = fullNum then
						state <= s0;
						isInit <= '1';
					else
						state <= s3;
					end if;
				when s4 =>
					--进行12个时钟周期采样，计数到十进制75
					if counter = X"4B" then
						state <= s5;
					else
						state <= s4;
					end if;
				when s5 =>
					--延迟16个时钟周期，到fullNum
					if counter = fullNum then
						if hscan_switch = '0' then
							--高速采样，100ns/div
							state <= s0;
						else
							--低速采样，20ms/div
							state <= s6;
						end if;
					else
						state <= s5;
					end if;
				when s6 =>
					if loopnum = X"C8" then
						state <= s0;
					else
						state <= s6;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when s0 =>
				ADC_CONVS <= '1';
			when s1 =>
				ADC_CONVS <= '0';
				ADC_SCLK <= '0';
			when s2 =>
				ADC_DIN <= InitData(conv_integer(counter - 64));
				ADC_SCLK <= not clk;
			when s3 =>
				ADC_CONVS <= '0';
				ADC_SCLK <= '0';
			when s4 =>
				ADC_CONVS <= '0';
				--下降沿读数
				if clk' event and clk = '0' then
					--只读十二位(可更改为其他位数）
					if(conv_integer(counter - 64) < 10) then
						data(conv_integer(counter - 64)) <= ADC_DOUT;
					end if;
				end if;
				ADC_SCLK <= clk;
			when s5 =>
				ADC_CONVS <= '0';
				ADC_SCLK <= '0';
			when s6 =>
				ADC_CONVS <= '0';
				ADC_SCLK <= '0';
		end case;
	end process;

	--计数模块
	process(clk, reset)
	begin
		if reset = '1' then
			counter <= (others => '0');
		elsif clk' event and clk = '1' then
			counter <= counter + 1;
			--计数到十进制80清零
			if counter = X"50" then
				counter <= (others => '0');
				loopnum <= loopnum + 1;
			end if;
			--loopnum计数降低采样频率200倍
			if loopnum = X"C8" then
				loopnum <= (others => '0');
			end if;
		end if;
	end process;
	
	--输出模块
	process(state)
	begin
		if state = s5 then
			q <= data;
		end if;
	end process;
	
end rtl;
