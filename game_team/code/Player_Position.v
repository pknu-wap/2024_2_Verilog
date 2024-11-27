module Player_Position (i_Clk, i_Rst, i_Btn_Left, i_Btn_Right, i_Player_Position
                        ,i_fTick, o_Player_Position);

    input i_Clk, i_Rst;
    input i_Btn_Left;
    input i_Btn_Right;
    input [9:0] i_Player_Position;
    input i_fTick;
    output [9:0] o_Player_Position;
    
    parameter MONITOR_WIDTH     = 10'd640;
    parameter PLAYER_WIDTH      = 10'd24;

    wire fPlayerLeftTouch, fPlayerRightTouch;

    assign fPlayerLeftTouch = ~|i_Player_Position;
    assign fPlayerRightTouch = i_Player_Position == MONITOR_WIDTH - PLAYER_WIDTH;

    assign o_Player_Position = 
        (i_Btn_Left  & ~fPlayerLeftTouch)   ? (i_Player_Position - 10'd1) :
        (i_Btn_Right & ~fPlayerRightTouch)  ? (i_Player_Position + 10'd1) : i_Player_Position;

endmodule