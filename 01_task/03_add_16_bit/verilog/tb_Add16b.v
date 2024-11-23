module tb_Add16b;

	reg [15:0] Add_i_A, Add_i_B;
	wire [15:0] Add_o_S;
	wire Add_o_C;

	// DUT inst
	Add16b U0(Add_i_A, Add_i_B, Add_o_S, Add_o_C);

	initial begin
		Add_i_A = 16'b1111011111111000; Add_i_B = 16'b0111100101100001;
		#10 Add_i_A = 16'b1110010111100001; Add_i_B = 16'b0111001110100011;
		#10 Add_i_A = 16'b0000010101101110; Add_i_B = 16'b1110101000000001;
		#10 Add_i_A = 16'b0011111100011011; Add_i_B = 16'b0100011011101010;
		#10 $stop;
	end

endmodule