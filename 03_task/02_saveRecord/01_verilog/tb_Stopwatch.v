`timescale 1ns / 1ns

module tb_Stopwatch;
    reg Clk, Rst;
    reg fStart, fStop, fRecord;

    Stopwatch U0(Clk, Rst, fStart, fStop, fRecord, , , , , , );
    
    always #10 Clk = ~Clk;
    
    initial begin
        // initialize
        {Clk, Rst, fStart, fStop, fRecord} = 5'b11111;
        
        // reset
        @(negedge Clk)  Rst = 0;        #1000   Rst = 1;

        // action
        #111_111_100    fStart = 0;     #1000   fStart = 1;
		#111_111_100    fRecord = 0;    #1000   fRecord = 1;
        #111_111_100    fStart = 0;     #1000   fStart = 1;
        #111_111_100    fRecord = 0;    #1000   fRecord = 1;
        #111_111_100    fStart = 0;     #1000   fStart = 1;
        #111_111_100    fRecord = 0;    #1000   fRecord = 1;
        #111_111_100    fStop = 0;      #1000   fStop = 1;
        #111_111_100    $stop;
    end
endmodule
