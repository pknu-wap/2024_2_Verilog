// 작업 중
module Collision
    #(
        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15, 

        parameter ENEMY_WIDTH       = 10'd36, 
        parameter ENEMY_HEIGHT      = 9'd24, 
        parameter PLAYER_WIDTH      = 10'd24, 
        parameter PLAYER_HEIGHT     = 9'd36, 
        parameter BULLET_WIDTH      = 10'd4, 
        parameter BULLET_HEIGHT     = 9'd16, 

        parameter NONE              = {19{1'b1}}
    ) (
        input   [MAX_ENEMY-1:0]         i_EnemyState, 
        input   [MAX_ENEMY_BULLET-1:0]  i_EnemyBulletState, 
        input                           i_PlayerState, 
        input   [MAX_PLAYER_BULLET-1:0] i_PlayerBulletState, 
        input   [18:0]                 	i_EnemyPosition         [MAX_ENEMY-1:0], 
        input   [18:0]                	i_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        input   [9:0]                   i_PlayerPosition, 
        input   [18:0]                  i_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0], 

        output  [MAX_ENEMY-1:0]         o_EnemyState, 
        output  [MAX_ENEMY_BULLET-1:0]  o_EnemyBulletState, 
        output                          o_PlayerState, 
        output  [MAX_PLAYER_BULLET-1:0] o_PlayerBulletState, 
        output  [18:0]                  o_EnemyPosition         [MAX_ENEMY-1:0], 
        output  [18:0]                  o_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        output  [9:0]                   o_PlayerPosition, 
        output  [18:0]                  o_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0]
    );

    integer i, j;

    // reg [MAX_ENEMY-1:0]          i_EnemyState, 
    // reg [MAX_ENEMY_BULLET-1:0]   i_EnemyBulletState, 
    // reg                          i_PlayerState, 
    // reg [MAX_PLAYER_BULLET-1:0]  i_PlayerBulletState, 
    // reg [18:0]                   i_EnemyPosition         [MAX_ENEMY-1:0], 
    // reg [18:0]                   i_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
    // reg [9:0]                    i_PlayerPosition, 
    // reg [18:0]                   i_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0]

    reg [MAX_ENEMY_BULLET-1:0]  temp0_EnemyBulletState;
    reg [MAX_PLAYER_BULLET-1:0] temp0_PlayerBulletState;
    reg [18:0]                  temp0_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];
    reg [18:0]                  temp0_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    reg [MAX_ENEMY-1:0]         temp1_EnemyState;
    reg [MAX_PLAYER_BULLET-1:0] temp1_PlayerBulletState;
    reg [18:0]                  temp1_EnemyPosition   [MAX_ENEMY-1:0];
    reg [18:0]                  temp1_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    reg horizontalCollision, verticalCollision;
    reg acb_X, adb_X, acb_Y, adb_Y;

    always @* begin
        // 적 탄 - 플레이어 탄 충돌 처리
        temp0_EnemyBulletState = i_EnemyBulletState;
        temp0_PlayerBulletState = i_PlayerBulletState;
        temp0_EnemyBulletPosition = i_EnemyBulletPosition;
        temp0_PlayerBulletPosition = i_PlayerBulletPosition;
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
            if (temp0_EnemyBulletState[i]) begin
                for (j = 0; j < MAX_PLAYER_BULLET; j = j + 1) begin: BulletCollisionLoop
                    if (temp0_PlayerBulletState[j]) begin
                        acb_X = (temp0_EnemyBulletPosition[i][18:9] <= temp0_PlayerBulletPosition[j][18:9]) & 
                                (temp0_PlayerBulletPosition[j][18:9] <= temp0_EnemyBulletPosition[i][18:9] + BULLET_WIDTH);
                        adb_X = (temp0_EnemyBulletPosition[i][18:9] <= temp0_PlayerBulletPosition[j][18:9] + BULLET_WIDTH) & 
                                (temp0_PlayerBulletPosition[j][18:9] + BULLET_WIDTH <= temp0_EnemyBulletPosition[i][18:9] + BULLET_WIDTH);
                        acb_Y = (temp0_EnemyBulletPosition[i][8:0] <= temp0_PlayerBulletPosition[j][8:0]) & 
                                (temp0_PlayerBulletPosition[j][8:0] <= temp0_EnemyBulletPosition[i][8:0] + BULLET_HEIGHT);
                        adb_Y = (temp0_EnemyBulletPosition[i][8:0] <= temp0_PlayerBulletPosition[j][8:0] + BULLET_HEIGHT) & 
                                (temp0_PlayerBulletPosition[j][8:0] + BULLET_HEIGHT <= temp0_EnemyBulletPosition[i][8:0] + BULLET_HEIGHT);
                        horizontalCollision = acb_X | adb_X;
                        verticalCollision = acb_Y | adb_Y;
                        if (horizontalCollision & verticalCollision) begin
                            temp0_EnemyBulletState[i] = 1'b0;
                            temp0_PlayerBulletState[j] = 1'b0;
                            temp0_EnemyBulletPosition[i] = NONE;
                            temp0_PlayerBulletPosition[j] = NONE;
                            disable BulletCollisionLoop;
                        end
                    end
                end
            end
        end

        // 적 - 플레이어 탄 충돌 처리
        temp1_EnemyState = i_EnemyState;
        temp1_PlayerBulletState = temp0_PlayerBulletState;
        temp1_EnemyPosition = i_EnemyPosition;
        temp1_PlayerBulletPosition = temp0_PlayerBulletPosition;
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
            if (temp1_EnemyState[i]) begin
                for (j = 0; j < MAX_PLAYER_BULLET; j = j + 1) begin: EnemyCollisionLoop
                    if (temp0_PlayerBulletState[j]) begin
                        acb_X = (temp0_EnemyPosition[i][18:9] <= temp0_PlayerBulletPosition[j][18:9]) & 
                                (temp0_PlayerBulletPosition[j][18:9] <= temp0_EnemyPosition[i][18:9] + ENEMY_WIDTH);
                        adb_X = (temp0_EnemyPosition[i][18:9] <= temp0_PlayerBulletPosition[j][18:9] + BULLET_WIDTH) & 
                                (temp0_PlayerBulletPosition[j][18:9] + BULLET_WIDTH <= temp0_EnemyPosition[i][18:9] + ENEMY_WIDTH);
                        acb_Y = (temp0_EnemyPosition[i][8:0] <= temp0_PlayerBulletPosition[j][8:0]) & 
                                (temp0_PlayerBulletPosition[j][8:0] <= temp0_EnemyPosition[i][8:0] + ENEMY_HEIGHT);
                        adb_Y = (temp0_EnemyPosition[i][8:0] <= temp0_PlayerBulletPosition[j][8:0] + BULLET_HEIGHT) & 
                                (temp0_PlayerBulletPosition[j][8:0] + BULLET_HEIGHT <= temp0_EnemyPosition[i][8:0] + ENEMY_HEIGHT);
                        horizontalCollision = acb_X | adb_X;
                        verticalCollision = acb_Y | adb_Y;
                        if (horizontalCollision & verticalCollision) begin
                            temp1_EnemyState[i] = 1'b0;
                            temp1_PlayerBulletState[j] = 1'b0;
                            temp1_EnemyPosition[i] = NONE;
                            temp1_PlayerBulletPosition[j] = NONE;
                            disable EnemyCollisionLoop;
                        end
                    end
                end
            end
        end

        // 플레이어 = 적 탄 충돌 처리
    end
    
endmodule
