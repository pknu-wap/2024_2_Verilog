module tb_PlayerEnemyBulletCC;
    reg Clk, Rst;

    reg [18:0] i_PlayerPos;
    reg [18:0] i_EnemyBulletPosition;
    
    wire o_IsCollision;

    PlayerEnemyBulletCC U0(i_PlayerPos, i_EnemyBulletPosition, o_IsCollision);

    always	#10	Clk = ~Clk;

	initial begin
		Clk = 0; Rst = 1;
        i_PlayerPos = 0;
        i_EnemyBulletPosition = 0;

		#100 Rst = 0; #10 Rst = 1;

        i_PlayerPos = {10'd200, 9'd200};
	end
        
endmodule