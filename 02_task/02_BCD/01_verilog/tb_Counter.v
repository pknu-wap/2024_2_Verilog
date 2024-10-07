`timescale 1 ns / 1ns
module tb_Cnt();

    reg Clk, Rst;
    reg [1:0] Push;
    wire [11:0] Cnt_o_LED;
    wire [20:0] Cnt_o_FND;

    wire Carry;

    Master_Counter U0(Clk, Rst, Push, Cnt_o_LED, Cnt_o_FND, Carry);

    always #10 Clk = ~Clk;

    initial begin
        // monitor
        $monitor("now: %d%d%d   push: %b    time: %8t", Cnt_o_LED[11:8], Cnt_o_LED[7:4], Cnt_o_LED[3:0], Push, $time);

        // initialize
        Clk = 1;
        Rst = 1;
        Push = 2'b11;

        // reset
        @(posedge Clk) Rst = 1;
        @(negedge Clk) Rst = 0;

        // action
        repeat (100) begin #200 Push = 2'b01; #200 Push = 2'b11; end

        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;

        repeat (100) begin #200 Push = 2'b10; #200 Push = 2'b11; end

        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;
        #200 Push = 2'b10; #200 Push = 2'b11;
        #200 Push = 2'b01; #200 Push = 2'b11;

        #200 $stop;
    end

endmodule
