module Bullet_Gen_And_Move 
    # (
        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15
    ) (
        input       [MAX_ENEMY_BULLET-1:0]  i_EnemyBulletState, 
        input       [MAX_PLAYER_BULLET-1:0] i_PlayerBulletState, 
        input       [18:0]                  i_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        input       [18:0]                  i_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0], 
        input       [MAX_ENEMY-1:0]         i_EnemyState, 
        input       [18:0]                  i_EnemyPosition         [MAX_ENEMY-1:0], 
        input       [8:0]                   i_StageState, 

        output reg  [MAX_ENEMY_BULLET-1:0]  o_EnemyBulletState, 
        output reg  [18:0]                  o_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        output reg  [18:0]                  o_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0]
    );

    integer i, j;

    reg [18:0] enemyBulletPositionTemp;

    always @* begin
        // 존재하는 탄을 이동
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

        // 발사될 적 탄을 추가
        if (i_StageState[6:0] == 7'b000_0000) begin                                         // phase가 시작되는 tick에서
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin                                     // 모든 적을 순회
                if (~i_EnemyState[i]) begin                                                 // 적이 존재하면
                    for (j = 0; j < MAX_ENEMY_BULLET; j = j + 1) begin                      // 모든 적 탄의 상태를 순회
                        if (~i_EnemyBulletState[j]) begin                                   // 적 탄이 존재하지 않는 인덱스에 적 탄을 생성
                            enemyBulletPositionTemp[18:9] = i_EnemyPosition[i][18:9] + 16;  // 적 탄의 가로 좌표 계산
                            enemyBulletPositionTemp[8:0] = i_EnemyPosition[i][8:0] + 24;    // 적 탄의 세로 좌표 계산
                            o_EnemyBulletPosition[j] = enemyBulletPositionTemp;             // 계산된 적 탄의 좌표 할당
                            o_EnemyBulletState[j] = 1'b1;                                   // 적 탄의 상태 최신화
                        end
                    end
                end
            end
        end


        // 발사될 플레이어 탄을 추가
    end

endmodule
