module tb_Add4b;
reg [3:0] Add_i_A;
reg [3:0] Add_i_B;
reg       Add_i_C;
wire [3:0] Add_o_S;
wire       Add_o_C;

Add4b U0(Add_i_A,Add_i_B,Add_o_S,Add_o_C);

initial begin
	    Add_i_C = 0;
	    Add_i_A = 4'b1010; 
	    Add_i_B = 4'b1100; 
	    #10 Add_i_A = 5; Add_i_B = 7;
	    #10 Add_i_A = 9; Add_i_B = 8;
end	    
	
endmodule