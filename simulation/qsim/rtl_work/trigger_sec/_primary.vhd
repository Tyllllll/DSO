library verilog;
use verilog.vl_types.all;
entity trigger_sec is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        start           : in     vl_logic;
        stop            : in     vl_logic;
        FIFO_data       : in     vl_logic_vector(9 downto 0);
        statetest       : out    vl_logic_vector(1 downto 0);
        pretest         : out    vl_logic_vector(9 downto 0);
        midtest         : out    vl_logic_vector(9 downto 0);
        retest          : out    vl_logic_vector(9 downto 0);
        countertest     : out    vl_logic_vector(1 downto 0);
        RAM_data        : out    vl_logic_vector(9 downto 0);
        trigger_FIFOR   : out    vl_logic;
        trigger_ready   : out    vl_logic
    );
end trigger_sec;
