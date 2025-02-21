library verilog;
use verilog.vl_types.all;
entity FIFO_vlg_sample_tst is
    port(
        aclr            : in     vl_logic;
        data            : in     vl_logic_vector(7 downto 0);
        rdclk           : in     vl_logic;
        rdreq           : in     vl_logic;
        wrclk           : in     vl_logic;
        wrreq           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end FIFO_vlg_sample_tst;
