module Collosion_Sample (i_Clk, i_Rst,Plyer_x,Plyer_y,
                         Enemy__Bullet_x, Enemy_Bullet_y);
                         
    input i_Clk;
    input i_Rst;
    input [4:0] Plyer_x;
    input [5:0] Plyer_y;
    input [2:0] Enemy__Bullet_x;
    input [4:0] Enemy_Bullet_y;
    
    //output reg i_fCollision;

    // 16ms 
    reg [19:0] tick_Counter; // 20??? 800,000?? ??? ??
    parameter LST_CLK = 800_000;
    wire tick;

    
    assign tick = (tick_Counter == 800_000);

    
    always @(posedge i_Clk or posedge i_Rst) begin
        if (i_Rst) begin
            tick_Counter <= 0;
        end else if (tick) begin
            tick_Counter <= 0;
        end else begin
            tick_Counter <= tick_Counter + 1;
        end
    end

    
    always @(posedge i_Clk or posedge i_Rst) begin
        if (i_Rst) begin
            i_fCollision <= 0;
        end else if (tick) begin
            if ((Plyer_x == Enemy__Bullet_x) 
                && (Plyer_y == Enemy_Bullet_y)) begin
                  i_fCollision <= 1;
            end else begin
                  i_fCollision <= 0;
            end
        end
    end
endmodule

