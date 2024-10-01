module tb_Addsub4b;
reg [3:0] Addsub_i_A;
reg [3:0] Addsub_i_B;
wire [3:0] Addsub_o_S;
wire Addsub_o_C;
reg Addsub_i_fSub;

Addsub4b U0(Addsub_i_A, Addsub_i_B, Addsub_o_S, Addsub_o_C);

initial
begin
  Addsub_i_A = 4'b1010;
  Addsub_i_B = 4'b1100;
  #10 Addsub_i_A = 5; Addsub_i_B = 7;
  #10 Addsub_i_A = 9; Addsub_i_B = 8;


end
endmodule
