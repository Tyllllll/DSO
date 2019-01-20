library verilog;
use verilog.vl_types.all;
entity trigger_sec_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        FIFO_data       : in     vl_logic_vector(9 downto 0);
        reset           : in     vl_logic;
        start           : in     vl_logic;
        stop            : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end trigger_sec_vlg_sample_tst;
