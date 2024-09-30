module tb_AddSub4b;

    reg [3:0] AddSub_i_A, AddSub_i_B;
    reg AddSub_i_fSub;
    wire [3:0] AddSub_o_S;
    wire AddSub_o_C;
	
    // DUT inst
    AddSub4b U0(AddSub_i_A, AddSub_i_B, AddSub_i_fSub, AddSub_o_S, AddSub_o_C);

    initial begin
        AddSub_i_A = 4'b0100; AddSub_i_B = 4'b0011; AddSub_i_fSub = 1'b0;
		#10 AddSub_i_A = 4'b0111; AddSub_i_B = 4'b0010; AddSub_i_fSub = 1'b1;
		#10 AddSub_i_A = 4'b1111; AddSub_i_B = 4'b0001; AddSub_i_fSub = 1'b0;
		#10 AddSub_i_A = 4'b0101; AddSub_i_B = 4'b1010; AddSub_i_fSub = 1'b1;
		#10 $stop;
    end

endmodule
