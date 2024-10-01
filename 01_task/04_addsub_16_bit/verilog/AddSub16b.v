module AddSub16b(i_A, i_B, i_fSub, o_S, o_C);

	input [15:0] i_A, i_B;
	input i_fSub;
	output [15:0] o_S;
	output o_C;
	wire [2:0] cout;

	wire [3:0] i_A0, i_A1, i_A2, i_A3;
	wire [3:0] i_B0, i_B1, i_B2, i_B3;
	wire [3:0] o_S0, o_S1, o_S2, o_S3;

	assign {i_A3, i_A2, i_A1, i_A0} = i_A;
	assign {i_B3, i_B2, i_B1, i_B0} = i_B;
	assign o_S = {o_S3, o_S2, o_S1, o_S0};

	AddSub4b AddSub4b0(i_A0, i_B0, i_fSub, i_fSub, o_S0, cout[0]);
	AddSub4b AddSub4b1(i_A1, i_B1, i_fSub, cout[0], o_S1, cout[1]);
	AddSub4b AddSub4b2(i_A2, i_B2, i_fSub, cout[1], o_S2, cout[2]);
	AddSub4b AddSub4b3(i_A3, i_B3, i_fSub, cout[2], o_S3, o_C);

endmodule
