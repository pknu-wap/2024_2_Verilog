module Player_Position (i_Btn_Left,i_Btn_Right,i_Player_Posion
                        ,i_fTick, o_Player_Position);
                        

    input i_Btn_Left;
    input i_Btn_Right;
    input [9:0] i_Player_Position;
    input i_fTick;
    output reg [9:0] o_PlayerPosition;
    
    assign o_PlayerPosition = 
        (i_Btn_Left  && i_PlayerPosition > 10'd0)             ? (i_PlayerPosition - 10'd1) :
        (i_Btn_Right && i_PlayerPosition < (10'd240 - 10'd24)) ? (i_PlayerPosition + 10'd1) :
                                                                i_PlayerPosition;

endmodule