library verilog;
use verilog.vl_types.all;
entity FND is
    port(
        i_NumA          : in     vl_logic_vector(3 downto 0);
        i_NumB          : in     vl_logic_vector(3 downto 0);
        o_FNDA          : out    vl_logic_vector(6 downto 0);
        o_FNDB          : out    vl_logic_vector(6 downto 0)
    );
end FND;
