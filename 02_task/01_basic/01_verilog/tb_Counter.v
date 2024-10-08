`timescale 1 ns / 1ns
module tb_Cnt();

    reg Clk;
    reg Rst;
    reg [1:0] Push;
    wire [3:0] Cnt_o_LED;

    Counter U0(Clk, Rst, Push, Cnt_o_LED,);

    always #10 Clk = ~Clk;

    initial begin
        // initialize
        Clk = 1;
        Rst = 1;
        Push = 2'b11;

        // reset
        @(posedge Clk) Rst = 1;
        @(negedge Clk) Rst = 0;

        // action
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
    end

endmodule
