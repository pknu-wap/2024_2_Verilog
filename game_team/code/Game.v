// 플레이어의 움직임, 탄 발사는 flag 신호로 처리하지 못함
// 
module Game 
    # (
        parameter GAME_IDLE     = 3'b000, 
        parameter GAME_PLAYING  = 3'b001, 
        parameter GAME_VICTORY  = 3'b010, 
        parameter GAME_DEFEAT   = 3'b011, 
        parameter GAME_ERROR    = 3'b100, 

        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15
    ) (
        input i_Clock, i_Reset, i_Tick, 
        input i_PlayerMoveLeft, i_PlayerMoveRight, i_PlayerBulletShoot, i_GameStartStop, 

        output [MAX_ENEMY-1:0]          o_EnemyState, 
        output [MAX_ENEMY_BULLET-1:0]   o_EnemyBulletState, 
        output                          o_PlayerState, 
        output [MAX_PLAYER_BULLET-1:0]  o_PlayerBulletState, 
        output [18:0]                   o_EnemyPosition           [MAX_ENEMY-1:0], 
        output [18:0]                   o_EnemyBulletPosition     [MAX_ENEMY_BULLET-1:0], 
        output [9:0]                    o_PlayerPosition, 
        output [18:0]                   o_PlayerBulletPosition    [MAX_PLAYER_BULLET-1:0], 
        output [2:0]                    o_GameState, 
        output [8:0]                    o_StageState, 
        output [13:0]                   o_Score
    );

    reg c_fPlayerLeft,      n_fPlayerLeft;
    reg c_fPlayerRight,     n_fPlayerRight;
    reg c_fPlayerShoot,     n_fPlayerShoot;
    reg c_fGameStartStop,   n_fGameStartStop;

    reg [MAX_ENEMY-1:0]         c_EnemyState,           n_EnemyState;
    reg [MAX_ENEMY_BULLET-1:0]  c_EnemyBulletState,     n_EnemyBulletState;
    reg                         c_PlayerState,          n_PlayerState;
    reg [MAX_PLAYER_BULLET-1:0] c_PlayerBulletState,    n_PlayerBulletState;
    
    reg [18:0]  c_EnemyPosition         [MAX_ENEMY-1:0],            n_EnemyPosition         [MAX_ENEMY-1:0];
    reg [18:0]  c_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0],     n_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];
    reg [9:0]   c_PlayerPosition,                                   n_PlayerPosition;
    reg [18:0]  c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    reg [2:0]   c_GameState,    n_GameState;
    reg [8:0]   c_StageState,   n_StageState;
    reg [13:0]  c_Score,        n_Score;

    wire fPlayerLeft;       // 필요 없음, playerLeft 그대로 받으면 됨
    wire fPlayerRight;      // 필요 없음, playerRight 그대로 받으면 됨
    wire fPlayerShoot;      // 개선 필요, 1회/12tick 측정하는 카운터 필요
    wire fGameStartStop;

    generate
        genvar i;
        for (i = 0; i < 5; i = i + 1) begin: firstRow
            First_Row_Enemy_Move Enemy_R1 (
                .i_EnemyState               (c_EnemyState[i]), 
                .i_EnemyHorizontalPosition  (c_EnemyPosition[i][18:9]), 
                .i_PhaseState               (c_StageState[8:7]), 
                .o_EnemyHorizontalPosition  (n_EnemyPosition[i][18:9])
            );
        end
        for (i = 5; i < 10; i = i + 1) begin: secondRow
            Second_Row_Enemy_Move Enemy_R2 (
                .i_EnemyState               (c_EnemyState[i]), 
                .i_EnemyHorizontalPosition  (c_EnemyPosition[i][18:9]), 
                .i_PhaseState               (c_StageState[8:7]), 
                .o_EnemyHorizontalPosition  (n_EnemyPosition[i][18:9])
            );
        end
        for (i = 10; i < 15; i = i + 1) begin: thirdRow
            Third_Row_Enemy_Move Enemy_R3 (
                .i_EnemyState               (c_EnemyState[i]), 
                .i_EnemyHorizontalPosition  (c_EnemyPosition[i][18:9]), 
                .i_PhaseState               (c_StageState[8:7]), 
                .o_EnemyHorizontalPosition  (n_EnemyPosition[i][18:9])
            );
        end
    endgenerate

    assign fPlayerLeft          = !i_PlayerMoveLeft       &   c_fPlayerLeft;
    assign fPlayerRight         = !i_PlayerMoveRight      &   c_fPlayerRight;
    assign fPlayerShoot         = !i_PlayerBulletShoot    &   c_fPlayerShoot;
    assign fGameStartStop       = !i_GameStartStop        &   c_fGameStartStop;

    assign o_EnemyState             = c_EnemyState;
    assign o_EnemyBulletState       = c_EnemyBulletState;
    assign o_PlayerState            = c_PlayerState;
    assign o_PlayerBulletState      = c_PlayerBulletState;
    assign o_EnemyPosition          = c_EnemyPosition;
    assign o_EnemyBulletPosition    = c_EnemyBulletPosition;
    assign o_PlayerPosition         = c_PlayerPosition;
    assign o_PlayerBulletPosition   = c_PlayerBulletPosition;
    assign o_GameState              = c_GameState;
    assign o_StageState             = c_StageState;
    assign o_Score                  = c_Score;

    always @(negedge i_Reset, posedge i_Tick) begin
        if (~i_Reset) begin
            // 리셋 정의


            
            c_GameState             = GAME_IDLE;

        end else begin
            c_fPlayerLeft           = n_fPlayerLeft;
            c_fPlayerRight          = n_fPlayerRight;
            c_fPlayerShoot          = n_fPlayerShoot;
            c_fGameStartStop        = n_fGameStartStop;
            c_EnemyState            = n_EnemyState;
            c_EnemyBulletState      = n_EnemyBulletState;
            c_PlayerState           = n_PlayerState;
            c_PlayerBulletState     = n_PlayerBulletState;
            c_EnemyPosition         = n_EnemyPosition;
            c_EnemyBulletPosition   = n_EnemyBulletPosition;
            c_PlayerPosition        = n_PlayerPosition;
            c_PlayerBulletPosition  = n_PlayerBulletPosition
            c_GameState             = n_GameState;
            c_StageState            = n_StageState;
            c_Score                 = n_Score;
        end
    end

    always @* begin
        n_fPlayerLeft       = i_PlayerMoveLeft;
        n_fPlayerRight      = i_PlayerMoveRight;
        n_fPlayerShoot      = i_PlayerBulletShoot;
        n_fGameStartStop    = i_GameStartStop;
        
        case (c_GameState)
            GAME_IDLE: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적
                n_EnemyState = 15'b111_1111_1111_1111;
                n_EnemyBulletState = 31'b000_0000_0000_0000_0000_0000_0000_0000;
                n_PlayerState = 1'b1;
                n_PlayerBulletState = 15'b000_0000_0000_0000;
                n_StageState = 9'b00_0000000;
                n_Score = 14'b00_0000_0000_0000;

                n_EnemyPosition

                if (fGameStartStop) n_GameState = GAME_PLAYING;
                else                n_GameState = GAME_IDLE;
            end
            GAME_PLAYING: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 스테이지
                // 2. 동작을 정의: 

                if (!(&c_EnemyState))         n_GameState = GAME_VICTORY;
                else if (!c_PlayerState)      n_GameState = GAME_DEFEAT;
                else if (fGameStartStop)    n_GameState = GAME_IDLE;
                else                        n_GameState = GAME_PLAYING;
            end
            GAME_VICTORY: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 
                // 2. 동작을 정의: 

                if (fGameStartStop) n_GameState = GAME_IDLE;
                else                n_GameState = GAME_VICTORY;
            end
            GAME_DEFEAT: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 
                // 2. 동작을 정의: 

                if (fGameStartStop) n_GameState = GAME_IDLE;
                else                n_GameState = GAME_DEFEAT;
            end
            GAME_ERROR: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 
                // 2. 동작을 정의: 
            end
        endcase
    end

endmodule
