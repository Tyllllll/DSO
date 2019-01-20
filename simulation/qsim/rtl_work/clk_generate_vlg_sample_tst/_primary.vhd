library verilog;
use verilog.vl_types.all;
entity clk_generate_vlg_sample_tst is
    port(
        clk40M          : in     vl_logic;
        reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end clk_generate_vlg_sample_tst;
