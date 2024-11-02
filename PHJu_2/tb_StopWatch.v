`timescale 1ns / 1ns
module tb_StopWatch;
    reg Clk;
    reg Rst;
    reg fRecord;
    reg fStart;
    reg fStop;

    StopWatch U0(Clk, Rst, fStart, fStop, fRecord, , );
    
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