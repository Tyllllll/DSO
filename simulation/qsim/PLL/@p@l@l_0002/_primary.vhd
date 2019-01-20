library verilog;
use verilog.vl_types.all;
entity PLL_0002 is
    port(
        refclk          : in     vl_logic;
        rst             : in     vl_logic;
        outclk_0        : out    vl_logic;
        locked          : out    vl_logic
    );
end PLL_0002;
