library verilog;
use verilog.vl_types.all;
entity AddSub4b is
    port(
        i_A             : in     vl_logic_vector(3 downto 0);
        i_B             : in     vl_logic_vector(3 downto 0);
        i_fSub          : in     vl_logic;
        o_S             : out    vl_logic_vector(3 downto 0);
        o_C             : out    vl_logic
    );
end AddSub4b;
