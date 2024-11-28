`timescale 1ns/1ns
module tb_Game_FND;
    reg Clk, Rst;

    wire    [6:0]   FND0;
    wire    [6:0]   FND1;
    wire    [6:0]   FND2;

    Game_FND UUT (
        .i_Clk(Clk), 
        .i_Rst(Rst), 
        .o_FND0(FND0), 
        .o_FND1(FND1), 
        .o_FND2(FND2) 
    );

    initial begin
        Clk = 0; Rst = 1;
        #10 Rst = 0;
        #10 Rst = 1;
    end

    always #10 Clk = ~Clk;

endmodule
