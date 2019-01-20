library verilog;
use verilog.vl_types.all;
entity clk_generate_vlg_check_tst is
    port(
        clk500k         : in     vl_logic;
        clk513k         : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end clk_generate_vlg_check_tst;
