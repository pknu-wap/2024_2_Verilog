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

    if (n_ClkCnt >= LST_CLK) begin
        n_ClkCnt = 0;

        if (c_GameStartStop == GAME_PLAYING) begin
                
                if (c_Sec0 == 9) begin
                    n_Sec0 = 0;

                    if (c_Sec1 == 9) begin
                        n_Sec1 = 0;

                        if (c_Sec2 == 9) begin
                            n_Sec2 = 0;
                        end else begin
                            n_Sec2 = c_Sec2 + 1;
                        end
                    end else begin
                        n_Sec1 = c_Sec1 + 1;
                    end
                end else begin
                    n_Sec0 = c_Sec0 + 1;
                end
            end
        end
    end


endmodule