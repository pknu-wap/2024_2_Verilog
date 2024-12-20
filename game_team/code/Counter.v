module Game_FND
    (
        input			i_Clk, i_Rst, 
        input   [2:0]   i_GameState, 
        output	[6:0]	o_FND0, o_FND1, o_FND2
    );

    parameter LST_CLK = 100_000_000 / 20 - 1;

    parameter GAME_IDLE         = 3'b000;
    parameter GAME_INIT         = 3'b001;
    parameter GAME_PLAYING      = 3'b010;
    parameter GAME_VICTORY      = 3'b011;
    parameter GAME_DEFEAT       = 3'b100;
    parameter GAME_ERROR        = 3'b101;

    reg [3:0]   c_Sec0, n_Sec0;
    reg [3:0]   c_Sec1, n_Sec1;
    reg [3:0]   c_Sec2, n_Sec2;
    reg [26:0]  c_ClkCnt, n_ClkCnt;
    
    wire fLstClk;
    wire fLstSec0, fLstSec1, fLstSec2;
    wire fIncSec0, fIncSec1, fIncSec2;

    assign fLstClk = c_ClkCnt == LST_CLK;
    assign fLstSec0 = c_Sec0 == 4'b1001;
    assign fLstSec1 = c_Sec1 == 4'b1001;
    assign fLstSec2 = c_Sec2 == 4'b1001;
    assign fIncSec0 = fLstClk;
    assign fIncSec1 = fIncSec0 & fLstSec0;
    assign fIncSec2 = fIncSec1 & fLstSec1;
    
    FND FND0(c_Sec0, o_FND0);
    FND FND1(c_Sec1, o_FND1);
    FND FND2(c_Sec2, o_FND2);

    always @(posedge i_Clk, negedge i_Rst) begin
        if (~i_Rst) begin
            c_ClkCnt = 27'd0;
            {c_Sec0, c_Sec1, c_Sec2} = {12{1'b0}};
        end else begin
            c_ClkCnt = n_ClkCnt;
            {c_Sec0, c_Sec1, c_Sec2} = {n_Sec0, n_Sec1, n_Sec2};
        end
    end

    always @* begin
        case (i_GameState)
            GAME_PLAYING: begin
                n_ClkCnt = fLstClk ? 27'd0 : c_ClkCnt + 1;
                n_Sec0 = fIncSec0 ? fLstSec0 ? 4'b0000 : c_Sec0 + 1 : c_Sec0;
                n_Sec1 = fIncSec1 ? fLstSec1 ? 4'b0000 : c_Sec1 + 1 : c_Sec1;
                n_Sec2 = fIncSec2 ? fLstSec2 ? 4'b0000 : c_Sec2 + 1 : c_Sec2;
            end
            GAME_VICTORY: begin
                n_ClkCnt = c_ClkCnt;
                n_Sec0 = c_Sec0;
                n_Sec1 = c_Sec1;
                n_Sec2 = c_Sec2;
            end
            GAME_DEFEAT: begin
                n_ClkCnt = c_ClkCnt;
                n_Sec0 = c_Sec0;
                n_Sec1 = c_Sec1;
                n_Sec2 = c_Sec2;
            end
            default: begin
                n_ClkCnt = 4'b0000;
                n_Sec0 = 4'b0000;
                n_Sec1 = 4'b0000;
                n_Sec2 = 4'b0000;
            end
        endcase
    end

endmodule
