module Collision
    #(
        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15
    ) (
        input	[MAX_ENEMY-1:0]         i_EnemyState, 
        input	[MAX_ENEMY_BULLET-1:0]  i_EnemyBulletState, 
        input                           i_PlayerState, 
        input	[MAX_PLAYER_BULLET-1:0]	i_PlayerBulletState, 
        input	[18:0]                 	i_EnemyPosition         [MAX_ENEMY-1:0], 
        input	[18:0]                	i_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        input	[9:0]                   i_PlayerPosition, 
        input	[18:0]                  i_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],

        output  [MAX_ENEMY-1:0]         o_EnemyState, 
        output  [MAX_ENEMY_BULLET-1:0]  o_EnemyBulletState, 
        output                          o_PlayerState, 
        output  [MAX_PLAYER_BULLET-1:0] o_PlayerBulletState, 
        output  [18:0]                  o_EnemyPosition         [MAX_ENEMY-1:0], 
        output  [18:0]                  o_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        output  [9:0]                   o_PlayerPosition, 
        output  [18:0]                  o_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0]
    );

    

endmodule