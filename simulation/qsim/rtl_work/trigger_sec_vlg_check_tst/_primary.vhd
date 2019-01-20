library verilog;
use verilog.vl_types.all;
entity trigger_sec_vlg_check_tst is
    port(
        countertest     : in     vl_logic_vector(1 downto 0);
        midtest         : in     vl_logic_vector(9 downto 0);
        pretest         : in     vl_logic_vector(9 downto 0);
        RAM_data        : in     vl_logic_vector(9 downto 0);
        retest          : in     vl_logic_vector(9 downto 0);
        statetest       : in     vl_logic_vector(1 downto 0);
        trigger_FIFOR   : in     vl_logic;
        trigger_ready   : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end trigger_sec_vlg_check_tst;
