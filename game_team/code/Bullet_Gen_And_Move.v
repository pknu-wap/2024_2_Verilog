// 수정 중
// i_ => temp_ => o_
module Bullet_Gen_And_Move 
    # (
        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15
    ) (
        input       [MAX_ENEMY-1:0]         i_EnemyState, 
        input       [MAX_ENEMY_BULLET-1:0]  i_EnemyBulletState, 
        input                               i_PlayerState, 
        input       [MAX_PLAYER_BULLET-1:0] i_PlayerBulletState, 
        input       [18:0]                  i_EnemyPosition         [MAX_ENEMY-1:0], 
        input       [18:0]                  i_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        input       [18:0]                  i_PlayerPosition, 
        input       [18:0]                  i_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0], 
        input                               i_fPlayerShoot, 
        input       [8:0]                   i_StageState, 

        output reg  [MAX_ENEMY_BULLET-1:0]  o_EnemyBulletState, 
        output reg  [MAX_PLAYER_BULLET-1:0] o_PlayerBulletState, 
        output reg  [18:0]                  o_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        output reg  [18:0]                  o_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0]
    );

    integer i, j;

    reg [MAX_ENEMY_BULLET-1:0]  temp0_EnemyBulletState;
    reg [MAX_PLAYER_BULLET-1:0] temp0_PlayerBulletState;
    reg [18:0]                  temp0_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];
    reg [18:0]                  temp0_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    always @* begin
        temp0_EnemyBulletState = i_EnemyBulletState;
        temp0_PlayerBulletState = i_PlayerBulletState;
        temp0_EnemyBulletPosition = i_EnemyBulletPosition;
        temp0_PlayerBulletPosition = i_PlayerBulletPosition;

        // 존재하는 적 탄을 이동
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
            if (temp0_EnemyBulletState[i]) begin
                temp0_EnemyBulletPosition[i] = {i_EnemyBulletPosition[i][18:9], i_EnemyBulletPosition[i][8:0] + 1'b1};
            end
        end

        // 존재하는 적 탄을 이동
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            if (temp0_PlayerBulletState[i]) begin
                temp0_PlayerBulletPosition[i] = {i_PlayerBulletPosition[i][18:9], i_PlayerBulletPosition[i][8:0] - 1'b1};
            end
        end

        // 발사될 적 탄을 추가
        if (i_StageState[6:0] == 7'b000_0000) begin                                         // phase가 시작되는 tick에서
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin                                     // 모든 적을 순회
                if (~i_EnemyState[i]) begin                                                 // 적이 존재하면
                    for (j = 0; j < MAX_ENEMY_BULLET; j = j + 1) begin: EnemyBulletLoop     // 모든 적 탄의 상태를 순회
                        if (~i_EnemyBulletState[j]) begin                                   // 적 탄이 존재하지 않는 인덱스에 적 탄을 생성
                            temp_EnemyBulletPosition[18:9] = i_EnemyPosition[i][18:9] + 16; // 적 탄의 가로 좌표 계산
                            temp_EnemyBulletPosition[8:0] = i_EnemyPosition[i][8:0] + 24;   // 적 탄의 세로 좌표 계산
                            o_EnemyBulletPosition[j] = temp_EnemyBulletPosition;            // 계산된 적 탄의 좌표 할당
                            o_EnemyBulletState[j] = 1'b1;                                   // 적 탄의 상태 최신화
                            disable EnemyBulletLoop;                                        // 반복문에서 탈출
                        end
                    end
                end
            end
        end

        // 발사될 플레이어 탄을 추가
        if (i_fPlayerShoot) begin                                                           // 플레이어 탄이 발사될 때
            if (i_PlayerState) begin                                                        // 플레이어가 존재한다면
                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin: PlayerBulletLoop       // 모든 플레이어 탄의 상태를 순회
                    if (~i_PlayerBulletState[i]) begin                                      // 플레이어 탄이 존재하지 않는 인덱스에 플레이어 탄을 생성
                        temp_PlayerBulletPosition[18:9] = i_PlayerPosition[18:9] + 10;      // 플레이어 탄의 가로 좌표 계산
                        temp_PlayerBulletPosition[8:0] = i_PlayerPosition[8:0] - 16;        // 플레이어 탄의 세로 좌표 계산
                        o_PlayerBulletPosition[i] = temp_PlayerBulletPosition;              // 계산된 플레이어 탄의 좌표 할당
                        o_PlayerBulletState[i] = 1'b1;                                      // 플레이어 탄의 상태 최신화
                        disable PlayerBulletLoop;                                           // 반복문에서 탈출
                    end
                end
            end
        end
    end

endmodule
