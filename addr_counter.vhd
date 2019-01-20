------------------------------------------------------------------------
--
--        Copyright (C) 2018
--        All rights reserved
--
--        filename: addr_counter
--
--        created by Tyl at 2019-01-06 09:36:22
--        modified by Tyl at 2019-01-10 13:52:03
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

entity addr_counter is
	port(
		clk, reset: in std_logic;
		RAMWCten: in std_logic;
		--RAMRCten: in std_logic;
		vga_R_addr: in std_logic_vector(11 downto 0);
		RAMWaddress: out std_logic_vector(11 downto 0);
		RAMWCO: out std_logic;
		RAMRaddress: out std_logic_vector(11 downto 0);
		RAMRCO: out std_logic
	);
end addr_counter;

architecture rtl of addr_counter is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1);

	-- Register to hold the current state
	signal state   : state_type;
	
	signal RAMWcounter: std_logic_vector(11 downto 0);
	signal RAMRcounter: std_logic_vector(11 downto 0);
begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '1' then
			RAMWcounter <= (others => '0');
			--RAMRcounter <= (others => '0');
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					if RAMWCten = '1'then
						state <= s1;
					else
						state <= s0;
					end if;
				when s1=>
					RAMWcounter <= RAMWcounter + 1;
					if RAMWCten = '0'then
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
				RAMWCO <= '0';
			when s1 =>
				if RAMWcounter = X"FFF" then
					RAMWCO <= '1';
				else
					RAMWCO <= '0';
				end if;
		end case;
	end process;
	
	--读地址计数
	RAMRcounter <= vga_R_addr;

	--地址输出模块
	RAMWaddress <= RAMWcounter;
	RAMRaddress <= RAMRcounter;
	
	--读地址进位输出模块
	process(RAMRcounter)
	begin
		if RAMRcounter = X"FFF" then
			RAMRCO <= '1';
		else
			RAMRCO <= '0';
		end if;
	end process;
end rtl;
