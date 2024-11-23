module FND(i_NumA, i_NumB, o_FNDA, o_FNDB);
  input [3:0] i_NumA;
  input [3:0] i_NumB;
  output reg [6:0] o_FNDA;
  output reg [6:0] o_FNDB;
 
  always@*
    case(i_NumA)
      4'h0: o_FNDA = 7'b1000000;
      4'h1: o_FNDA = 7'b1111001;
      4'h2: o_FNDA = 7'b0100100;
      4'h3: o_FNDA = 7'b0110000;
      4'h4: o_FNDA = 7'b0011001;
      4'h5: o_FNDA = 7'b0010010;
      4'h6: o_FNDA = 7'b0000010;
      4'h7: o_FNDA = 7'b1111000;
      4'h8: o_FNDA = 7'b0000000;
      4'h9: o_FNDA = 7'b0010000;
      default: o_FNDA = 7'b1111111;
  endcase
  
  always@*
    case(i_NumB)
      4'h0: o_FNDB = 7'b1000000;
      4'h1: o_FNDB = 7'b1111001;
      4'h2: o_FNDB = 7'b0100100;
      4'h3: o_FNDB = 7'b0110000;
      4'h4: o_FNDB = 7'b0011001;
      4'h5: o_FNDB = 7'b0010010;
      4'h6: o_FNDB = 7'b0000010;
      4'h7: o_FNDB = 7'b1111000;
      4'h8: o_FNDB = 7'b0000000;
      4'h9: o_FNDB = 7'b0010000;
      default: o_FNDB = 7'b1111111;
  endcase
 
endmodule