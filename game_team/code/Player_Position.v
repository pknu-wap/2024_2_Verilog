module Player_Position (i_Btn_Left,i_Btn_Right,i_Player_Posion
                        ,i_fTick, o_Player_Position);

    input i_Btn_Left;
    input i_Btn_Right;
    input [9:0] i_Player_Position;
    input i_fTick;
    output reg [9:0] o_PlayerPosition;
    
    parameter MONITOR_WIDTH     = 10'd640;
    parameter PLAYER_WIDTH      = 10'd24;

    wire fPlayerLeftTouch, fPlayerRightTouch;

    assign fPlayerLeftTouch = ~|i_PlayerPosition;
    assign fPlayerRightTouch = i_PlayerPosition == MONITOR_WIDTH - PLAYER_WIDTH;

    assign o_PlayerPosition = 
        (i_Btn_Left  & ~fPlayerLeftTouch)   ? (i_PlayerPosition - 10'd1) :
        (i_Btn_Right & ~fPlayerRightTouch)  ? (i_PlayerPosition + 10'd1) : i_PlayerPosition;

endmodule