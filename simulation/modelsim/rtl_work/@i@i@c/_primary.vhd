library verilog;
use verilog.vl_types.all;
entity IIC is
    generic(
        OS              : vl_logic := Hi1;
        MUX             : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        PGA             : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        MODE            : vl_logic := Hi1;
        DR              : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi1);
        COMP_MODE       : vl_logic := Hi0;
        COMP_POL        : vl_logic := Hi0;
        COMP_LAT        : vl_logic := Hi0;
        COMP_QUE        : vl_logic_vector(0 to 1) := (Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sda             : inout  vl_logic;
        scl             : out    vl_logic;
        data            : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of OS : constant is 1;
    attribute mti_svvh_generic_type of MUX : constant is 1;
    attribute mti_svvh_generic_type of PGA : constant is 1;
    attribute mti_svvh_generic_type of MODE : constant is 1;
    attribute mti_svvh_generic_type of DR : constant is 1;
    attribute mti_svvh_generic_type of COMP_MODE : constant is 1;
    attribute mti_svvh_generic_type of COMP_POL : constant is 1;
    attribute mti_svvh_generic_type of COMP_LAT : constant is 1;
    attribute mti_svvh_generic_type of COMP_QUE : constant is 1;
end IIC;
