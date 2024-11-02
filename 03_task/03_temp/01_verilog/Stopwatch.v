module Stopwatch(i_Clk, i_Rst, i_fStart, i_fStop, i_fRecord, o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5);
    input i_Clk, i_Rst;
    input i_fStart, i_fStop, i_fRecord;
    output [6:0] o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5;

    reg [1:0] c_State, n_State;
    reg [3:0] c_Sec0, n_Sec0;
    reg [3:0] c_Sec1, n_Sec1;
    reg [3:0] c_Sec2, n_Sec2;
    reg [3:0] c_Sec3, n_Sec3;
    reg [3:0] c_Sec4, n_Sec4;
    reg [3:0] c_Sec5, n_Sec5;
    reg [22:0] c_ClkCnt, n_ClkCnt;
    reg c_fStart;
    reg c_fStop;
    reg c_fRecord;

    wire fLstClk;
    wire fLstSec0, fLstSec1, fLstSec2;
    wire fIncSec0, fIncSec1, fIncSec2;
    wire fStart, fStop, fRecord;

    parameter LST_CLK = 100_000_000 / 20 - 1;
    parameter IDLE = 2'b00, WORK = 2'b01, PAUSE = 2'b10;

    FND FND0(c_Sec0, o_Sec0);
    FND FND1(c_Sec1, o_Sec1);
    FND FND2(c_Sec2, o_Sec2);
    FND FND3(c_Sec3, o_Sec3);
    FND FND4(c_Sec4, o_Sec4);
    FND FND5(c_Sec5, o_Sec5);
    
    always @(posedge i_Clk, negedge i_Rst)
        if (!i_Rst) begin
            c_State = IDLE;
            c_ClkCnt = 23'd0;
            {c_Sec0, c_Sec1, c_Sec2, c_Sec3, c_Sec4, c_Sec5} = 24'b0000_0000_0000_0000_0000_0000;
            {c_fStart, c_fStop, c_fRecord} = 3'b111;
        end else begin
            c_State = n_State;
            c_ClkCnt = n_ClkCnt;
            {c_Sec0, c_Sec1, c_Sec2, c_Sec3, c_Sec4, c_Sec5} = {n_Sec0, n_Sec1, n_Sec2, n_Sec3, n_Sec4, n_Sec5};
            {c_fStart, c_fStop, c_fRecord} = {i_fStart, i_fStop, i_fRecord};
        end
    
    assign fLstClk = c_ClkCnt == LST_CLK;
    assign fLstSec0 = c_Sec0 == 4'b1001;
    assign fLstSec1 = c_Sec1 == 4'b1001;
    assign fLstSec2 = c_Sec2 == 4'b1001;
    assign fIncSec0 = fLstClk;
    assign fIncSec1 = fIncSec0 & fLstSec0;
    assign fIncSec2 = fIncSec1 & fLstSec1;
    assign fStart = !i_fStart & c_fStart;
    assign fStop = !i_fStop & c_fStop;
    assign fRecord = !i_fRecord & c_fRecord;

    always @* begin
        case (c_State)
            IDLE: begin
                n_ClkCnt = 0;
                {n_Sec0, n_Sec1, n_Sec2, n_Sec3, n_Sec4, n_Sec5} = 6'b000000;
                n_State = fStart ? WORK : IDLE;
            end
            WORK: begin
                n_ClkCnt = fLstClk ? 23'd0 : c_ClkCnt + 1;
                n_Sec0 = fIncSec0 ? fLstSec0 ? 4'b0000 : c_Sec0 + 1 : c_Sec0;
                n_Sec1 = fIncSec1 ? fLstSec1 ? 4'b0000 : c_Sec1 + 1 : c_Sec1;
                n_Sec2 = fIncSec2 ? fLstSec2 ? 4'b0000 : c_Sec2 + 1 : c_Sec2;
                n_State = fStop ? IDLE : fStart ? PAUSE : WORK;
                if (fRecord) {n_Sec3, n_Sec4, n_Sec5} = {c_Sec0, c_Sec1, c_Sec2};
            end
            PAUSE: begin
                n_State = fStop ? IDLE : fStart ? WORK : PAUSE;
                if (fRecord) {n_Sec3, n_Sec4, n_Sec5} = {c_Sec0, c_Sec1, c_Sec2};
            end
        endcase
    end
endmodule
