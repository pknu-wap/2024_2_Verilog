`timescale 1ps/1ps
module tb_CollisionTest;
	reg Clk, Rst;

	CollisionTest UUT(Clk, Rst);

	initial begin
		Clk = 1'b0; Rst = 1'b1;
		#100 Rst = 1'b0;	#10 Rst = 1'b1;
	end

	always #10 Clk = ~Clk;
endmodule