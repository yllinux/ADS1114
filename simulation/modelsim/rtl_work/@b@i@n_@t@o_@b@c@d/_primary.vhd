library verilog;
use verilog.vl_types.all;
entity BIN_TO_BCD is
    port(
        bin             : in     vl_logic_vector(9 downto 0);
        bcd             : out    vl_logic_vector(15 downto 0)
    );
end BIN_TO_BCD;
