library verilog;
use verilog.vl_types.all;
entity FRE_DIV is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        clk_div         : out    vl_logic
    );
end FRE_DIV;
