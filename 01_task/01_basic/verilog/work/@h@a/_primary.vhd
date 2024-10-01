library verilog;
use verilog.vl_types.all;
entity HA is
    port(
        i_A             : in     vl_logic;
        i_B             : in     vl_logic;
        o_S             : out    vl_logic;
        o_C             : out    vl_logic
    );
end HA;
