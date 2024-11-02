module Master_Counter(i_Clk, i_Rst, i_Push, o_LED, o_FND);
	input i_Clk, i_Rst;
	input [1:0] i_Push;
	output [11:0] o_LED;
	output [20:0] o_FND;

	wire [3:0] o_LED0, o_LED1, o_LED2;
	wire [6:0] o_FND0, o_FND1, o_FND2;
	wire [1:0] Carry0, Carry1, Carry2;

	assign o_LED = {o_LED2, o_LED1, o_LED0};
	assign o_FND = {o_FND2, o_FND1, o_FND0};

	Counter U0(i_Clk, i_Rst, i_Push, o_LED0, o_FND0, Carry0);
	Counter U1(i_Clk, i_Rst, Carry0, o_LED1, o_FND1, Carry1);
	Counter U2(i_Clk, i_Rst, Carry1, o_LED2, o_FND2, Carry2);
endmodule
