module HA(i_A, i_B, o_S, o_C);
input i_A, i_B;
output o_S;
output o_C;
assign o_S = i_A ^ i_B;
assign o_C = i_A & i_B;
endmodule