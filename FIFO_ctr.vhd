------------------------------------------------------------------------
--
--        Copyright (C) 2018
--        All rights reserved
--
--        filename: FIFO_ctr
--
--        created by Tyl at 2019-01-06 08:48:20
--        modified by Tyl at 2019-01-09 16:20:25
--
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity FIFO_ctr is
	port(
		clk, reset: in std_logic;
		FIFOWFull: in std_logic;
		FIFOREmpty: in std_logic;
		trigger_FIFOR: in std_logic;
		FIFOWen: out std_logic;
		FIFORen: out std_logic
	);
end FIFO_ctr;

architecture bhv of FIFO_ctr is
begin
	process(clk, reset)
	begin
		if reset = '1' then
			FIFOWen <= '0';
			FIFORen <= '0';
		elsif clk' event and clk = '1' then
			if FIFOWFull = '1' then
				FIFOWen <= '0';
				FIFORen <= '0';
			elsif FIFOREmpty = '1' then
				FIFOWen <= '1';
				FIFORen <= '0';
			else
				FIFOWen <= '1';
				FIFORen <= trigger_FIFOR;
			end if;
		end if;
	end process;
end bhv;