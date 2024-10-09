library verilog;
use verilog.vl_types.all;
entity Counter is
    port(
        i_Clk           : in     vl_logic;
        i_Rst           : in     vl_logic;
        i_Push          : in     vl_logic_vector(1 downto 0);
        o_LED           : out    vl_logic_vector(3 downto 0);
        o_FNDA          : out    vl_logic_vector(6 downto 0);
        o_FNDB          : out    vl_logic_vector(6 downto 0)
    );
end Counter;
