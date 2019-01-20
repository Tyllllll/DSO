library verilog;
use verilog.vl_types.all;
entity AD_ctr_vlg_check_tst is
    port(
        ADC_CONVS       : in     vl_logic;
        ADC_DIN         : in     vl_logic;
        ADC_SCLK        : in     vl_logic;
        clk500k         : in     vl_logic;
        q               : in     vl_logic_vector(9 downto 0);
        sampler_rx      : in     vl_logic
    );
end AD_ctr_vlg_check_tst;
