library verilog;
use verilog.vl_types.all;
entity SHIFT is
    port(
        din             : in     vl_logic_vector(25 downto 0);
        dout            : out    vl_logic_vector(25 downto 0)
    );
end SHIFT;
