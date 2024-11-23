module HA(i_A,i_B,i_C,o_S,o_C);
input i_A,i_B,i_C;
output o_S,o_C;
wire HA0_o_S,HA0_o_C;
wire HA1_o_S,HA1_o_C;

HA Ha0(i_A,i_B,HA0_o_S,HA0_o_C);
HA Ha1(HA0_o_S,i_C,HA1_o_S,HA1_o_C);

assign o_S = HA1_o_S,
       o_C = HA0_o_C|HA1_o_C;
       
endmodule
