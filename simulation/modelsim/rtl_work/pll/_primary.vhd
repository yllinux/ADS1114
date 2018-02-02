library verilog;
use verilog.vl_types.all;
entity pll is
    generic(
        CLK0_MUL        : integer := 1;
        CLK0_DIV        : integer := 1;
        CLK1_MUL        : integer := 3;
        CLK1_DIV        : integer := 1;
        CLK2_MUL        : integer := 1;
        CLK2_DIV        : integer := 5
    );
    port(
        areset          : in     vl_logic;
        inclk0          : in     vl_logic;
        c0              : out    vl_logic;
        c1              : out    vl_logic;
        c2              : out    vl_logic;
        locked          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK0_MUL : constant is 1;
    attribute mti_svvh_generic_type of CLK0_DIV : constant is 1;
    attribute mti_svvh_generic_type of CLK1_MUL : constant is 1;
    attribute mti_svvh_generic_type of CLK1_DIV : constant is 1;
    attribute mti_svvh_generic_type of CLK2_MUL : constant is 1;
    attribute mti_svvh_generic_type of CLK2_DIV : constant is 1;
end pll;
