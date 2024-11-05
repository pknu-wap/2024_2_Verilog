module Stop_Watch_n(i_Clk, i_Rst, i_fStart, i_fStop, i_fRecord, o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5);
    input i_Clk, i_Rst;
    input i_fStart, i_fStop, i_fRecord;
    output wire [6:0] o_Sec0, o_Sec1, o_Sec2, o_Sec3, o_Sec4, o_Sec5;

    reg [1:0] c_State, n_State;
    reg [3:0] c_Sec0, n_Sec0;
    reg [3:0] c_Sec2, n_Sec2;
    reg [3:0] c_Sec1, n_Sec1;
    reg [3:0] c_Sec3, n_Sec3;
    reg [3:0] c_Sec4, n_Sec4;
    reg [3:0] c_Sec5, n_Sec5;
    reg [22:0] c_ClkCnt, n_ClkCnt;
    reg c_fStart, n_fStart;
    reg c_fStop, n_fStop;
    reg c_fRecord, n_fRecord;

    wire fLstClk;
    wire fLstSec0, fLstSec1, fLstSec2, fLstSec3, fLstSec4, fLstSec5;
    wire fIncSec0, fIncSec1, fIncSec2, fIncSec3, fIncSec4, fIncSec5;
    wire fStart, fStop, fRecord;

    parameter LST_CLK = 100_000_000/20 - 1;
    parameter IDLE = 2'b00, WORK = 2'b01, PAUSE = 2'b10, RECORD = 2'b11;

    FND FND0(c_Sec0, o_Sec0);
    FND FND1(c_Sec1, o_Sec1);
    FND FND2(c_Sec2, o_Sec2);
    FND FND3(c_Sec3, o_Sec3);
    FND FND4(c_Sec4, o_Sec4);
    FND FND5(c_Sec5, o_Sec5);
    
    always@(posedge i_Clk, negedge i_Rst)
        if(!i_Rst) begin
            c_State = IDLE;
            c_ClkCnt = 0;
            c_Sec0 = 0;
            c_Sec1 = 0;
            c_Sec2 = 0;
            c_Sec3 = 0;
            c_Sec4 = 0;
            c_Sec5 = 0;  
            c_fStart = 1;
            c_fStop = 1;
        end else begin
            c_State = n_State ;
            c_ClkCnt = n_ClkCnt ;
            c_Sec0 = n_Sec0 ;
            c_Sec1 = n_Sec1 ;
            c_Sec2 = n_Sec2 ;
            c_Sec3 = n_Sec3 ;
            c_Sec4 = n_Sec4 ;
            c_Sec5 = n_Sec5 ;
            c_fStart = n_fStart ;
            c_fStop = n_fStop ;
        end

    assign fStart = !i_fStart && c_fStart,
           fStop = !i_fStop && c_fStop,
           fRecord = !i_fRecord && c_fRecord;
    assign fLstClk = c_ClkCnt == LST_CLK,
           fLstSec0= c_Sec0 == 9,
           fLstSec1= c_Sec1 == 9,
           fLstSec2= c_Sec2 == 9;
    
    assign fIncSec0= fLstClk,
           fIncSec1= fIncSec0 && fLstSec0,
           fIncSec2= fIncSec1 && fLstSec1;

    always@*
        begin
             n_fStart = i_fStart ;
             n_fStop = i_fStop ;
             n_fRecord = i_fRecord ;
             n_State = c_State ;
             n_ClkCnt = c_ClkCnt ;
             n_Sec0 = c_Sec0 ;
             n_Sec1 = c_Sec1 ;
             n_Sec2 = c_Sec2 ;
             n_Sec3 = c_Sec3;
             n_Sec4 = c_Sec4;
             n_Sec5 = c_Sec5;
        
        case(c_State)
            IDLE: begin
                n_ClkCnt = 0;
                n_Sec0 = 0;
                n_Sec1 = 0;
                n_Sec2 = 0;
                n_Sec3 = 0;
                n_Sec4 = 0;
                n_Sec5 = 0;
                if(fStart) n_State = WORK;
            end
            WORK: begin
                n_ClkCnt = fLstClk ? 0 : c_ClkCnt + 1;
                n_Sec0 = fIncSec0 ? fLstSec0 ? 0 : c_Sec0 + 1 : c_Sec0;
                n_Sec1 = fIncSec1 ? fLstSec1 ? 0 : c_Sec1 + 1 : c_Sec1;
                n_Sec2 = fIncSec2 ? fLstSec2 ? 0 : c_Sec2 + 1 : c_Sec2;
                if(fStop) n_State = IDLE;
                else if(fStart) n_State = PAUSE;
                else if(fRecord) n_State = RECORD;
            end
            RECORD: begin
                n_Sec3 = c_Sec0;
                n_Sec4 = c_Sec1;
                n_Sec5 = c_Sec2;
                if(fStop) n_State = IDLE;
                else if(fStart) n_State = WORK;
            end
            PAUSE: begin
                if(fStop) begin
                   n_State = IDLE;
                   n_Sec3 = 0;
                   n_Sec4 = 0;
                   n_Sec5 = 0;
                end
                else if(fStart)n_State = WORK;         
              end
        endcase
    end
endmodule
