module Player_Position (i_Clk, i_Rst,i_Btn_Left,i_Btn_Right,i_Player_Posion
                        ,i_fTick, o_Player_Position);
                        
    input i_Clk;
    input i_Rst;
    input i_Btn_Left;
    input i_Btn_Right;
    input [9:0] i_Player_Position;
    input i_fTick;
    output reg [9:0] o_PlayerPosition;
    
    always @(posedge i_Clk or posedge i_Rst) begin
        if (i_Rst) begin
            o_PlayerPosition <= 10'd0;         end else if (i_fTick) begin
          
            
            if (i_Btn_Left && i_Player_Position > 10'd0) begin
                o_PlayerPosition <= i_Player_Position - 10'd1;
            end else if (i_Btn_Right && i_Player_Position < (10'd240 - 10'd24)) begin
                o_PlayerPosition <= i_Player_Position + 10'd1;
            end else begin
                o_PlayerPosition <= i_Player_Position;            
            end
        end
    end

endmodule