library verilog;
use verilog.vl_types.all;
entity measuring is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        hscan_switch    : in     vl_logic;
        data            : in     vl_logic_vector(9 downto 0);
        freqout         : out    vl_logic_vector(23 downto 0);
        volout          : out    vl_logic_vector(11 downto 0)
    );
end measuring;
