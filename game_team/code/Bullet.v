module Bullet (
	i_EnemyBulletState, i_PlayerBulletState, i_EnemyBulletPosition, i_PlayerBulletPosition
);

	parameter MAX_ENEMY			= 4'b1111;	// 4'd15
	parameter MAX_ENEMY_BULLET	= 5'b11111;	// 4'd31
	parameter MAX_PLAYER_BULLET	= 4'b1111;	// 4'd15

	integer i, j;

	input		[MAX_ENEMY_BULLET-1:0]	i_EnemyBulletState;
	input		[MAX_PLAYER_BULLET-1:0]	i_PlayerBulletState;
	input		[18:0]					i_EnemyBulletPosition	[MAX_ENEMY_BULLET-1:0];
	input		[18:0]					i_PlayerBulletPosition	[MAX_PLAYER_BULLET-1:0];

	output reg	[18:0]					o_EnemyBulletPosition	[MAX_ENEMY_BULLET-1:0];
	output reg	[18:0]					o_PlayerBulletPosition	[MAX_PLAYER_BULLET-1:0];

	always @* begin
		for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
			if (i_EnemyBulletState[i]) begin
				o_EnemyBulletPosition[i] = {i_EnemyBulletPosition[i][18:9], i_EnemyBulletPosition[i][8:0] + 1'b1};
			end
		end

		for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
			if (i_PlayerBulletState[i]) begin
				o_PlayerBulletPosition[i] = {i_PlayerBulletPosition[i][18:9], i_PlayerBulletPosition[i][8:0] - 1'b1};
			end
		end
	end

endmodule
