module tb_AddSub16b;

	reg [15:0] AddSub_i_A, AddSub_i_B;
	reg AddSub_i_fSub;
	wire [15:0] AddSub_o_S;
	wire AddSub_o_C;

	// DUT inst
	AddSub16b U0(AddSub_i_A, AddSub_i_B, AddSub_i_fSub, AddSub_o_S, AddSub_o_C);

	initial begin
		AddSub_i_A = 16'b1111011111111000; AddSub_i_B = 16'b0111100101100001; AddSub_i_fSub = 1'b1;
		#10 AddSub_i_A = 16'b1110010111100001; AddSub_i_B = 16'b0111001110100011;
		#10 AddSub_i_A = 16'b0000010101101110; AddSub_i_B = 16'b1110101000000001;
		#10 AddSub_i_A = 16'b0011111100011011; AddSub_i_B = 16'b0100011011101010;
		#10 $stop;
	end

endmodule
