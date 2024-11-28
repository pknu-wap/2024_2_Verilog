module FND_GALAGA(i_Clk, i_Rst, i_fGameStartStop,
				  o_Sec0, o_Sec1, o_Sec2,);

	input i_Clk, i_Rst;
	input i_fGameStartStop;
	ouput wire [6:0] o_Sec0, o_Sec1, o_Sec2;

	parameter LST_CLK = 100_000_000/20 - 1;
    parameter IDLE = 2'b00, WORK = 2'b01, Stop = 2'b10;

	reg [1:0] c_GameStartStop,n_GameStartStop;

	reg [3:0] c_Sec0, n_Sec0;
    reg [3:0] c_Sec1, n_Sec1;
	reg [3:0] c_Sec2, n_Sec2;

	reg [22:0] c_ClkCnt, n_ClkCnt;
    reg c_fGameStartStop, n_fGameStartStop;

	wire fLstClk;
    reg c_fStart, n_fStart;
    reg c_fStop, n_fStop;

    wire fLstSec0, fLstSec1, fLstSec2;
	wire fIncSec0, fIncSec1, fIncSec2;

	wire fGameStartStop;
	wire fStart, fStop;
	
	FND FND0(c_Sec0, o_Sec0);
    FND FND1(c_Sec1, o_Sec1);
    FND FND2(c_Sec2, o_Sec2);

     always@(posedge i_Clk, negedge i_Rst) //??? ?? ? 0
    
        if(!i_Rst) begin
            c_State = GAME_IDLE;
            c_ClkCnt = 0;
            c_Sec0 = 0;
            c_Sec1 = 0;
            c_Sec2 = 0; 
            c_fStart = 1;
            c_fStop = 1;
        end else begin
            c_State = n_State ;
            c_ClkCnt = n_ClkCnt ;
            c_Sec0 = n_Sec0 ;
            c_Sec1 = n_Sec1 ;
            c_Sec2 = n_Sec2 ;
            c_fStart = n_fStart ;
            c_fStop = n_fStop ;
        end 

        assign fStart = !i_fStart && c_fStart,
               fStop = !i_fStop && c_fStop;
        
        assign fLstClk = c_ClkCnt == LST_CLK,
               fLstSec0= c_Sec0 == 9,
               fLstSec1= c_Sec1 == 9,
               fLstSec2= c_Sec2 == 9;

        assign fIncSec0= fLstClk,
               fIncSec1= fIncSec0 && fLstSec0,
               fIncSec2= fIncSec1 && fLstSec1;

        case(c_GameStartStop)
            GAME_IDLE: begin
                n_ClkCnt = 0;
                n_Sec0 = 0;
                n_Sec1 = 0;
                n_Sec2 = 0;
                if(fStart) n_State = WORK;
            end
            GAME_PLAYING: begin
                n_ClkCnt = fLstClk ? 0 : c_ClkCnt + 1;
                n_Sec0 = fIncSec0 ? fLstSec0 ? 0 : c_Sec0 + 1 : c_Sec0;
                n_Sec1 = fIncSec1 ? fLstSec1 ? 0 : c_Sec1 + 1 : c_Sec1;
                n_Sec2 = fIncSec2 ? fLstSec2 ? 0 : c_Sec2 + 1 : c_Sec2;
                if(fStop) n_State = IDLE;
                else if(fStart)n_State = PAUSE;
            end
            GAME_INITIAL: begin
                if(fStop) n_State = IDLE;
                else if(fStart)n_State = WORK;
            end
        endcase
endmodule