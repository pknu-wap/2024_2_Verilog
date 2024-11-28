`timescale 1ps/1ps
module tb_GALAGA;
	reg Clk, Rst;

	GALAGA UUT(Clk, Rst, , );

	always	#10	Clk = ~Clk;

	initial begin
		Clk = 0; Rst = 1;
		#100 Rst = 0; #10 Rst = 1;
	end
endmodule