module Master_Counter(i_Clk, i_Rst, i_Toggle, i_Push, o_LED, o_FND);

	input i_Clk, i_Rst;
	input i_Toggle, i_Push;
	output [11:0] o_LED;
	output [20:0] o_FND;

	reg UpDnMode; // 0이면 상향 카운터, 1이면 하향 카운터

	wire [3:0] LED0, LED1, LED2;
	wire [6:0] FND0, FND1, FND2;
	wire Carry0, Carry1, Carry2;

	Counter U0(i_Clk, i_Rst, UpDnMode, i_Push, LED0, FND0, Carry0);
	Counter U1(i_Clk, i_Rst, UpDnMode, Carry0, LED1, FND1, Carry1);
	Counter U2(i_Clk, i_Rst, UpDnMode, Carry1, LED2, FND2, Carry2);

	assign o_LED = {LED2, LED1, LED0};
	assign o_FND = {FND2, FND1, FND0};

	always @(posedge i_Rst)
		UpDnMode = 1'b0;
	
	always @(negedge i_Toggle)
		UpDnMode = ~UpDnMode;

endmodule
