`timescale 1 ns / 1ns
module tb_Cnt();

    reg Clk, Rst;
    reg Toggle, Push;
    wire [11:0] Cnt_o_LED;
    wire [20:0] Cnt_o_FND;

    Master_Counter U0(Clk, Rst, Toggle, Push, Cnt_o_LED, Cnt_o_FND);

    always #10 Clk = ~Clk;

    initial begin
        // monitor
        $monitor("now: %d%d%d   Toggle: %b    push: %b    time: %8t", Cnt_o_LED[11:8], Cnt_o_LED[7:4], Cnt_o_LED[3:0], Toggle, Push, $time);

        // initialize
        Clk = 1'b1;
        Rst = 1'b1;
        Toggle = 1'b1;
        Push = 1'b1;

        // reset
        @(posedge Clk) Rst = 1'b1;
        @(negedge Clk) Rst = 1'b0;

        // action
        repeat (100) begin #200 Push = 1'b0; #200 Push = 1'b1; end

        #200 Toggle = 1'b0; #200 Toggle = 1'b1; #200 Push = 1'b0; #200 Push = 1'b1;
        #200 Toggle = 1'b0; #200 Toggle = 1'b1; #200 Push = 1'b0; #200 Push = 1'b1;
        #200 Toggle = 1'b0; #200 Toggle = 1'b1; #200 Push = 1'b0; #200 Push = 1'b1;
        #200 Toggle = 1'b0; #200 Toggle = 1'b1; #200 Push = 1'b0; #200 Push = 1'b1;
        #200 Toggle = 1'b0; #200 Toggle = 1'b1;

        repeat (100) begin #200 Push = 1'b0; #200 Push = 2'b1; end

        #200 Push = 1'b0; #200 Push = 1'b1;
        #200 Toggle = 1'b0; #200 Toggle = 1'b1; #200 Push = 1'b0; #200 Push = 1'b1;
        #200 Toggle = 1'b0; #200 Toggle = 1'b1; #200 Push = 1'b0; #200 Push = 1'b1;
        #200 Toggle = 1'b0; #200 Toggle = 1'b1; #200 Push = 1'b0; #200 Push = 1'b1;

        #200 $stop;
    end

endmodule
