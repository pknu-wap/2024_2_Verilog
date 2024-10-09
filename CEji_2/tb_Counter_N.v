`timescale 1 ns / 1ns
module tb_Cnt_N();
    reg Clk;
    reg Rst;
    reg [2:0] Push;
    wire[3:0] Cnt_o_LED;

    Counter_N U0(Clk, Rst, Push, Cnt_o_LED,);

    always
        #10 Clk = ~Clk;

    initial
        begin
            // initialize
            Clk = 1;
            Rst = 1;
            Push = 3'b111;

            // reset
            @(posedge Clk) Rst = 1;
            @(negedge Clk) Rst = 0;

            // action
            #200 Push = 3'b110; #200 Push = 3'b111; //1
            #200 Push = 3'b110; #200 Push = 3'b111; //2
            #200 Push = 3'b011; #200 Push = 3'b111; //5
            #200 Push = 3'b101; #200 Push = 3'b111; //4
            #200 Push = 3'b101; #200 Push = 3'b111; //3
            #200 Push = 3'b101;                     //2
        end
endmodule
