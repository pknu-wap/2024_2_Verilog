module tb_Add16b;
reg       [15:0]     Add_i_A;
reg       [15:0]     Add_i_B;
wire[15:0] Add_o_S;
wire      Add_o_C;
reg       Add_i_C;

Add16b U0(Add_i_A, Add_i_B, Add_o_S, Add_o_C);

initial
begin
         Add_i_C = 0;
         Add_i_A = 16'b0000_0000_0000_1010; Add_i_B = 16'b0000_0000_0000_1100;
         #10 Add_i_A = 5; Add_i_B = 7;
         #10 Add_i_A = 9; Add_i_B = 8;
end
endmodule
