module Add16b(i_A, i_B, o_S, o_C);

	input [15:0] i_A, i_B;
	output [15:0] o_S;
	output o_C;
	wire [2:0] cout;

	wire [3:0] i_A0, i_A1, i_A2, i_A3;
	wire [3:0] i_B0, i_B1, i_B2, i_B3;
	wire [3:0] o_S0, o_S1, o_S2, o_S3;

	assign {i_A3, i_A2, i_A1, i_A0} = i_A;
	assign {i_B3, i_B2, i_B1, i_B0} = i_B;
	assign o_S = {o_S3, o_S2, o_S1, o_S0};

	Add4b Add4b0(i_A0, i_B0, 1'b0, o_S0, cout[0]);
	Add4b Add4b1(i_A1, i_B1, cout[0], o_S1, cout[1]);
	Add4b Add4b2(i_A2, i_B2, cout[1], o_S2, cout[2]);
	Add4b Add4b3(i_A3, i_B3, cout[2], o_S3, o_C);

endmodule
