library verilog;
use verilog.vl_types.all;
entity DATA is
    generic(
        H_ACT           : vl_logic_vector(0 to 11) := (Hi0, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        V_ACT           : vl_logic_vector(0 to 11) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi1, Hi0, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        din             : in     vl_logic_vector(23 downto 0);
        key_data        : in     vl_logic_vector(3 downto 0);
        X               : in     vl_logic_vector(11 downto 0);
        Y               : in     vl_logic_vector(11 downto 0);
        data            : out    vl_logic_vector(23 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of H_ACT : constant is 1;
    attribute mti_svvh_generic_type of V_ACT : constant is 1;
end DATA;
