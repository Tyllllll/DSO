library verilog;
use verilog.vl_types.all;
entity measuring_vlg_check_tst is
    port(
        freqout         : in     vl_logic_vector(23 downto 0);
        volout          : in     vl_logic_vector(11 downto 0);
        sampler_rx      : in     vl_logic
    );
end measuring_vlg_check_tst;
