library verilog;
use verilog.vl_types.all;
entity FIFO_vlg_check_tst is
    port(
        q               : in     vl_logic_vector(9 downto 0);
        rdempty         : in     vl_logic;
        rdusedw         : in     vl_logic_vector(9 downto 0);
        wrfull          : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end FIFO_vlg_check_tst;
