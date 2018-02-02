library verilog;
use verilog.vl_types.all;
entity SEG7 is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        key2            : in     vl_logic_vector(3 downto 0);
        data            : in     vl_logic_vector(15 downto 0);
        seg             : out    vl_logic_vector(7 downto 0);
        sel             : out    vl_logic_vector(5 downto 0)
    );
end SEG7;
