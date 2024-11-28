module tb_Game_FND;
    reg	[9:0] Score;
    wire    [6:0]   FND0;
    wire    [6:0]   FND1;
    wire    [6:0]   FND2;

    Game_FND UUT (
        .i_Score(Score), 
        .o_FND0(FND0), 
        .o_FND1(FND1), 
        .o_FND2(FND2) 
    );

    initial begin
        Score = 10'd837;
        #10 Score = 10'd354;
    end
endmodule