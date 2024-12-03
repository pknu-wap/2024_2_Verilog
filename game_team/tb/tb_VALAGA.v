`timescale 1ps/1ps
module tb_VALAGA;

	reg 		Clk, Rst;
	reg	[3:0]	Btn;

	VALAGA UUT (Clk, Rst, Btn,,,,,,,,,,);

	initial begin
		Clk = 1;
		Rst = 0;
		Btn = {4{1'b1}};

		@(negedge Clk) Rst = 1;
		#1000	Btn	= 4'b0000;
		#1000	Btn = 4'b1111;
        #1000	Btn	= 4'b0111;
		#1000	Btn = 4'b1111;
		#1000	Btn	= 4'b1101;
		#1000	Btn = 4'b1111;
		#1000	Btn	= 4'b1101;
		#1000	Btn = 4'b1111;
		#1000	Btn	= 4'b1101;
		#1000	Btn = 4'b1111;
		#1000	Btn	= 4'b1011;
		#1000	Btn = 4'b1111;
		#1000	Btn	= 4'b1011;
		#1000	Btn = 4'b1111;
		#1000	Btn	= 4'b1101;
		#1000	Btn = 4'b1111;		
		// more...
	end

	always #10 Clk = ~Clk;

endmodule
