library verilog;
use verilog.vl_types.all;
entity clk_generate is
    port(
        clk40M          : in     vl_logic;
        reset           : in     vl_logic;
        clk500k         : out    vl_logic;
        clk513k         : out    vl_logic
    );
end clk_generate;
