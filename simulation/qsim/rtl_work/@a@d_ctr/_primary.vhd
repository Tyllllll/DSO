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
        q               : out    vl_logic_vector(9 downto 0);
        clk500k         : out    vl_logic
    );
end AD_ctr;
