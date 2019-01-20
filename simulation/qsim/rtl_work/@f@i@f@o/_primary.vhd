library verilog;
use verilog.vl_types.all;
entity FIFO is
    port(
        aclr            : in     vl_logic;
        data            : in     vl_logic_vector(9 downto 0);
        rdclk           : in     vl_logic;
        rdreq           : in     vl_logic;
        wrclk           : in     vl_logic;
        wrreq           : in     vl_logic;
        q               : out    vl_logic_vector(9 downto 0);
        rdempty         : out    vl_logic;
        rdusedw         : out    vl_logic_vector(9 downto 0);
        wrfull          : out    vl_logic
    );
end FIFO;
