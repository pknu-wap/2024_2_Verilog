module Player_Position (i_Clk, i_Rst, i_btn_Left, i_btn_Right,
                        Player_x,Player_y);

    input i_Clk;
    input i_Rst;
    input i_btn_Left;
    input i_btn_Right;    
    output reg [4:0] Player_x;
    output reg [4:0] Player_y;
    
    initial begin
        Player_x = 0;
        Player_y = 0;
    end

  
    always @(posedge i_Clk or posedge i_Rst) begin
      
        if (i_Rst) begin
            Player_x <= 0;
            Player_y <= 0;
            
        end else begin
          
            if (i_btn_Left && Player_x > 0) begin
                Player_x <= Player_x - 1; 
                
            end else if (i_btn_Right && Player_x < (240 - 24)) begin
                Player_x <= Player_x + 1;
            end
        end
    end
endmodule
