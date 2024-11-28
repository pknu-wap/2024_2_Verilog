`timescale 1ns / 1ps

module tb_Player_Position();

    
    reg i_Clk, i_Rst;
    reg i_Btn_Left, i_Btn_Right;
    reg i_fTick;
    reg [9:0] i_Player_Position;
    wire [9:0] o_PlayerPosition;

    parameter CLK_PERIOD = 16; 

   
    Player_Position uut (
        .i_Clk(i_Clk),
        .i_Rst(i_Rst),
        .i_Btn_Left(i_Btn_Left),
        .i_Btn_Right(i_Btn_Right),
        .i_Player_Position(i_Player_Position),
        .i_fTick(i_fTick),
        .o_PlayerPosition(o_PlayerPosition)
    );

    always #(CLK_PERIOD / 2) i_Clk = ~i_Clk;
    
    initial begin
        
        i_Clk = 0;
        i_Rst = 0;
        i_Btn_Left = 0;
        i_Btn_Right = 0;
        i_fTick = 0;
        i_Player_Position = 10'd320;
        
        #5 i_Rst = 1;
        #15 i_Rst = 0;

        #10 i_fTick = 1; #200i_Btn_Left = 1;
        #20 i_fTick = 0; #200i_Btn_Left = 0;
        #30 i_fTick = 1; #200i_Btn_Right = 1;
        #20 i_fTick = 0; #200i_Btn_Right = 0;
        #10 i_fTick = 1; #200i_Btn_Right = 1;
        #20 i_fTick = 0; #200i_Btn_Right = 0;

        #10 i_Player_Position = 10'd0;
        #10 i_fTick = 1; #200i_Btn_Left = 1;
        #20 i_fTick = 0; #200i_Btn_Left = 0;

        #10 i_Player_Position = 10'd616;
        #10 i_fTick = 1; #200i_Btn_Right = 1;
        #20 i_fTick = 0; #200i_Btn_Right = 0;

        #50 $stop;
    end

    always @(posedge i_Clk) begin
        if (i_fTick)
            i_Player_Position <= o_PlayerPosition;
    end

endmodule

