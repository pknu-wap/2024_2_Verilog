`timescale 1ns / 1ps

module tb_GARAGA();
  reg Clk;
  reg Rst;
  reg pixalState;

  GALAGA U0(Clk, Rst, pixalState);

  always #10 Clk = ~Clk;

  initial begin
    Clk = 1;
    Rst = 0;

    @(negedge Clk) Rst = 1;
    #50;
    $finish;
  end
endmodule