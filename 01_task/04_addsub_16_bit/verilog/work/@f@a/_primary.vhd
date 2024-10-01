library verilog;
use verilog.vl_types.all;
entity FA is
    port(
        i_A             : in     vl_logic;
        i_B             : in     vl_logic;
        i_C             : in     vl_logic;
        o_S             : out    vl_logic;
        o_C             : out    vl_logic
    );
end FA;
