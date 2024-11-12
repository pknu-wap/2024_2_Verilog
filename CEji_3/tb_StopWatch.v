`timescale 1ns / 1ps
module tb_StopWatch;
    reg Clk;
    reg Rst;
    reg fStart;
    reg fStop;
    reg fRecord;
    wire [6:0] o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5;

    Stop_Watch_n U0(Clk, Rst, fStart, fStop, fRecord, o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5);
    
    always #10 Clk = ~Clk;
    
    initial 
    begin
        Clk = 1;
        Rst = 0;
        fStart = 1;
        fStop = 1;
        fRecord = 1;
        
        @(negedge Clk) Rst = 1;
        #1_000_000 fStart = 0; #20 fStart = 1;
        #500_000_000 fStart = 0; #20 fStart = 1;
        #500_000_000 fStart = 0; #20 fStart = 1;
        #500_000_000 fRecord = 0; #10_000_000 fRecord = 1;
        #500_000_000 fRecord = 0; #10_000_000 fRecord = 1;
        #1_000_000 fStop = 0; #20 fStop = 1;
        $stop;
end
endmodule
