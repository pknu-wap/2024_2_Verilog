`timescale 1ns / 1ns
module tb_StopWatch;
    reg Clk;
    reg Rst;
    reg fStart;
    reg fStop;

    StopWatch U0(Clk, Rst, fStart, fStop, , , );
    
    always #10 Clk = ~Clk;
    
    initial 
    begin
        Clk = 1;
        Rst = 0;
        fStart = 1;
        fStop = 1;
        
        @(negedge Clk) Rst = 1;
        #1000 fStart = 0; #20 fStart = 1;
        #222_222_200 fStart = 0; #20 fStart = 1;
        #222_222_200 fStart = 0; #20 fStart = 1;
        #222_222_200 fStart = 0; #20 fStart = 1;
        #222_222_200 fStart = 0; #20 fStart = 1;
        #333 fStop = 0; #20 fStop = 1;
        $stop;
    end
endmodule