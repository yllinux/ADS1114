library verilog;
use verilog.vl_types.all;
entity CMP is
    port(
        cmp_in          : in     vl_logic_vector(3 downto 0);
        cmp_out         : out    vl_logic_vector(3 downto 0)
    );
end CMP;
