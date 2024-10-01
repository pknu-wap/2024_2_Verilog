module Add16b(i_A, i_B, o_S, o_C);
input [15:0]i_A, i_B;
output wire [15:0] o_S;
output wire o_C;
wire [14:0] cout;

FA FA0(i_A[0], i_B[0], 1'b0, o_S[0], cout[0]);
FA FA1(i_A[1], i_B[1], cout[0], o_S[1], cout[1]);
FA FA2(i_A[2], i_B[2], cout[1], o_S[2], cout[2]);
FA FA3(i_A[3], i_B[3], cout[2], o_S[3], cout[3]);
FA FA4(i_A[4], i_B[4], cout[3], o_S[4], cout[4]);
FA FA5(i_A[5], i_B[5], cout[4], o_S[5], cout[5]);
FA FA6(i_A[6], i_B[6], cout[5], o_S[6], cout[6]);
FA FA7(i_A[7], i_B[7], cout[6], o_S[7], cout[7]);
FA FA8(i_A[8], i_B[8], cout[7], o_S[8], cout[8]);
FA FA9(i_A[9], i_B[9], cout[8], o_S[9], cout[9]);
FA FA10(i_A[10], i_B[10], cout[9], o_S[10], cout[10]);
FA FA11(i_A[11], i_B[11], cout[10], o_S[11], cout[11]);
FA FA12(i_A[12], i_B[12], cout[11], o_S[12], cout[12]);
FA FA13(i_A[13], i_B[13], cout[12], o_S[13], cout[13]);
FA FA14(i_A[14], i_B[14], cout[13], o_S[14], cout[14]);
FA FA15(i_A[15], i_B[15], cout[14], o_S[15], o_C);

endmodule
