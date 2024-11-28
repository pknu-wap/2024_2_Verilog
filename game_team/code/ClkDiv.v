module ClkDiv(
	input Clk,
	output Clk25m);


	reg r_Clk = 0;

	assign Clk25m = r_Clk;

always@(posedge Clk) 
begin
	r_Clk = ~r_Clk;
end


endmodule