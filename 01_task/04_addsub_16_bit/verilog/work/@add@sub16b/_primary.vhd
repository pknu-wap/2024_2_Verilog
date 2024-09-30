library verilog;
use verilog.vl_types.all;
entity AddSub16b is
    port(
        i_A             : in     vl_logic_vector(15 downto 0);
        i_B             : in     vl_logic_vector(15 downto 0);
        i_fSub          : in     vl_logic;
        o_S             : out    vl_logic_vector(15 downto 0);
        o_C             : out    vl_logic
    );
end AddSub16b;
