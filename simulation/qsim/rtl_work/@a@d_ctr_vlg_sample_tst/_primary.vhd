library verilog;
use verilog.vl_types.all;
entity AD_ctr_vlg_sample_tst is
    port(
        ADC_DOUT        : in     vl_logic;
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end AD_ctr_vlg_sample_tst;
