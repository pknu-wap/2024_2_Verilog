module Addsub4b(i_A, i_B, i_fSub, o_S, o_C);
input [3:0]i_A, i_B;
input i_fSub;
output wire[3:0] o_S;
output wire o_C;
wire[2:0] cout;

FA HA0(i_A[0], i_B[0]^i_fSub, i_fSub, o_S[0], cout[0]);
FA HA1(i_A[1], i_B[1]^i_fSub, cout[0], o_S[1], cout[0]);
FA HA2(i_A[2], i_B[2]^i_fSub, cout[1], o_S[2], cout[0]);
FA HA3(i_A[3], i_B[3]^i_fSub, cout[2], o_S[3], o_C);

endmodule
