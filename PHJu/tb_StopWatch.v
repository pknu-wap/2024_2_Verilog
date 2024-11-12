`timescale 1ns / 1ns
module tb_StopWatch;
    reg Clk;
    reg Rst;
    reg fRecord;
    reg fStart;
    reg fStop;
    wire [6:0] o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5;


    StopWatch U0(Clk, Rst, fRecord, fStart, fStop, o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5);
    
    always #10 Clk = ~Clk;
    
    initial 
    begin
        Clk = 1;
        Rst = 0;
        fStart = 1;
        fStop = 1;
        fRecord =1;
        
        @(negedge Clk) Rst = 1;
        #100 fStart = 0; #20 fStart = 1;

        #500 fRecord = 0; #20 fRecord = 1;

        #1000 fStart = 0; #20 fStart = 1;

        #500 fStop = 0; #20 fStop = 1;
        $stop;
    end
endmodule