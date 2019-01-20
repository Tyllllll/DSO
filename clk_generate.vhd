------------------------------------------------------------------------
--
--        Copyright (C) 2018
--        All rights reserved
--
--        filename: clk_generate
--
--        created by Tyl at 2019-01-09 21:01:06
--        modified by Tyl at 2019-01-09 21:26:44
--
------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity clk_generate is
	port(
		clk40M: in std_logic;
		reset: in std_logic;
		clk500k: out std_logic;
		clk513k: out std_logic
	);
end clk_generate;

architecture bhv of clk_generate is
	signal counter500k: integer range 0 to 39;
	signal clk500ktemp: std_logic := '0';
	signal counter513k: integer range 0 to 38;
	signal clk513ktemp: std_logic := '0';
begin
	process(clk40M, reset)
	begin
		if reset = '1' then
			counter500k <= 0;
		elsif clk40M' event and clk40M = '1' then
			counter500k <= counter500k + 1;
		end if;
	end process;
	
	process(clk40M)
	begin
		if clk40M' event and clk40M = '1' then
			if counter500k = 0 then
				clk500ktemp <= not clk500ktemp;
			end if;
		end if;
	end process;
	
	clk500k <= clk500ktemp;
	
	process(clk40M, reset)
	begin
		if reset = '1' then
			counter513k <= 0;
		elsif clk40M' event and clk40M = '1' then
			counter513k <= counter513k + 1;
		end if;
	end process;
	
	process(clk40M)
	begin
		if clk40M' event and clk40M = '1' then
			if counter513k = 0 then
				clk513ktemp <= not clk513ktemp;
			end if;
		end if;
	end process;
	
	clk513k <= clk513ktemp;
end bhv;