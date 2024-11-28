`timescale 1ps/1ps
module tb_Game;

	reg 		Clk, Rst;
	reg	[3:0]	Btn;

	Game UUT (
		.i_Clk(Clk), 
		.i_Rst(Rst), 
		.i_Btn(Btn), , , , , , , , , ,
	);

	initial begin
		Clk = 0;
		Rst = 1;
		Btn = {4{1'b1}};
		#100	Rst = 0;
		#10		Rst = 1;
		#1000	Btn	= 4'b1011;
		#1000	Btn = 4'b1111;
		// more...
	end

	always #10 Clk = ~Clk;

endmodule
