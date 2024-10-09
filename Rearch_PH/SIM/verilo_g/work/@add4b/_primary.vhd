library verilog;
use verilog.vl_types.all;
entity Add4b is
    port(
        i_A             : in     vl_logic_vector(3 downto 0);
        i_B             : in     vl_logic_vector(3 downto 0);
        o_S             : out    vl_logic_vector(3 downto 0);
        o_C             : out    vl_logic
    );
end Add4b;
