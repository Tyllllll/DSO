library verilog;
use verilog.vl_types.all;
entity AD_ctr is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        ADC_DOUT        : in     vl_logic;
        ADC_CONVS       : out    vl_logic;
        ADC_DIN         : out    vl_logic;
        ADC_SCLK        : out    vl_logic;
        q               : out    vl_logic_vector(0 to 11)
    );
end AD_ctr;
