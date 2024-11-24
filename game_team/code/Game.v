// 플레이어의 움직임, 탄 발사는 flag 신호로 처리하지 못함
// 
module Game 
    # (
        parameter GAME_IDLE         = 3'b000, 
        parameter GAME_PLAYING      = 3'b001, 
        parameter GAME_VICTORY      = 3'b010, 
        parameter GAME_DEFEAT       = 3'b011, 
        parameter GAME_ERROR        = 3'b100, 

        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15, 

        parameter ENEMY_CENTER_X    = 10'd302, 
        parameter ENEMY_CENTER_Y    = 9'd108, 
        parameter ENEMY_GAP_X       = 10'd72, 
        parameter ENEMY_GAP_Y       = 9'd60, 
        parameter PLAYER_CENTER_X   = 10'd302, 
        parameter PLAYER_CENTER_Y   = 9'd372
    ) (
        input   i_Clock, i_Reset, i_Tick, 
        input   i_PlayerMoveLeft, i_PlayerMoveRight, i_PlayerBulletShoot, i_GameStartStop, 

        output  [MAX_ENEMY-1:0]         o_EnemyState, 
        output  [MAX_ENEMY_BULLET-1:0]  o_EnemyBulletState, 
        output                          o_PlayerState, 
        output  [MAX_PLAYER_BULLET-1:0] o_PlayerBulletState, 
        output  [18:0]                  o_EnemyPosition         [MAX_ENEMY-1:0], 
        output  [18:0]                  o_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        output  [9:0]                   o_PlayerPosition, 
        output  [18:0]                  o_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0], 
        output  [2:0]                   o_GameState, 
        output  [8:0]                   o_StageState, 
        output  [13:0]                  o_Score
    );

    integer i, j;
    genvar  gen_i, gen_j, gen_k;

    // reg c_fPlayerLeft,      n_fPlayerLeft;
    // reg c_fPlayerRight,     n_fPlayerRight;
    reg [3:0]   c_fPlayerShoot,     n_fPlayerShoot;     // 0부터 11까지의 값을 저장
    reg         c_fGameStartStop,   n_fGameStartStop;

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

    reg [MAX_ENEMY_BULLET-1:0]  temp_EnemyBulletState;
    reg [MAX_PLAYER_BULLET-1:0] temp_PlayerBulletState;
    reg [18:0]                  temp_EnemyPosition          [MAX_ENEMY-1:0];
    reg [9:0]                   temp_PlayerPosition;
    reg [18:0]                  temp_EnemyBulletPosition    [MAX_ENEMY_BULLET-1:0];
    reg [18:0]                  temp_PlayerBulletPosition   [MAX_PLAYER_BULLET-1:0];

    // wire fPlayerLeft;    // 필요 없음, playerLeft 그대로 받으면 됨
    // wire fPlayerRight;   // 필요 없음, playerRight 그대로 받으면 됨
    wire fPlayerShoot;      // 개선 필요, 1회/12tick 측정하는 카운터 필요
    wire fGameStartStop;

    generate
        for (gen_i = 0; gen_i < 5; gen_i = gen_i + 1) begin: firstRow
            First_Row_Enemy_Move Enemy_R1 (
                .i_EnemyState       (c_EnemyState[gen_i]), 
                .i_EnemyPosition    (c_EnemyPosition[gen_i]), 
                .i_PhaseState       (c_StageState[8:7]), 
                .o_EnemyPosition    (temp_EnemyPosition[gen_i])
            );
        end
        for (gen_j = 0; gen_j < 5; gen_j = gen_j + 1) begin: secondRow
            Second_Row_Enemy_Move Enemy_R2 (
                .i_EnemyState       (c_EnemyState[gen_j]), 
                .i_EnemyPosition    (c_EnemyPosition[gen_j]), 
                .i_PhaseState       (c_StageState[8:7]), 
                .o_EnemyPosition    (temp_EnemyPosition[gen_j])
            );
        end
        for (gen_k = 0; gen_k < 5; gen_k = gen_k + 1) begin: thirdRow
            Third_Row_Enemy_Move Enemy_R3 (
                .i_EnemyState       (c_EnemyState[gen_k]), 
                .i_EnemyPosition    (c_EnemyPosition[gen_k]), 
                .i_PhaseState       (c_StageState[8:7]), 
                .o_EnemyPosition    (temp_EnemyPosition[gen_k])
            );
        end

        Bullet_Gen_And_Move U0 (
            .i_EnemyState           (c_EnemyState), 
            .i_EnemyBulletState     (c_EnemyBulletPosition), 
            .i_PlayerState          (c_PlayerState), 
            .i_PlayerBulletState    (c_PlayerBulletState), 
            .i_EnemyPosition        (temp_EnemyPosition), 
            .i_EnemyBulletPosition  (c_EnemyBulletPosition), 
            .i_PlayerPosition       (temp_PlayerPosition), 
            .i_PlayerBulletPosition (c_PlayerBulletPosition), 
            .i_fPlayerShoot         (fPlayerShoot), 
            .i_StageState           (c_StageState), 
            .o_EnemyBulletState     (temp_EnemyBulletState), 
            .o_PlayerBulletState    (temp_PlayerBulletState), 
            .o_EnemyBulletPosition  (temp_EnemyBulletPosition), 
            .o_PlayerBulletPosition (temp_PlayerBulletPosition)
        );
    endgenerate

    // assign fPlayerLeft           = !i_PlayerMoveLeft     &   c_fPlayerLeft;
    // assign fPlayerRight          = !i_PlayerMoveRight    &   c_fPlayerRight;
    assign fPlayerShoot             = ~i_PlayerBulletShoot  &   ~|c_fPlayerShoot;   // flag가 0일 때 발사 가능
    assign fGameStartStop           = ~i_GameStartStop      &   c_fGameStartStop;

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
            // c_fPlayerLeft           = 1'b1;
            // c_fPlayerRight          = 1'b1;
            c_fPlayerShoot          = 4'd11;
            c_fGameStartStop        = 1'b1;

            c_EnemyState            = 15'b111_1111_1111_1111;
            c_EnemyBulletState      = 31'b000_0000_0000_0000_0000_0000_0000_0000;
            c_PlayerState           = 1'b1;
            c_PlayerBulletState     = 15'b000_0000_0000_0000;

            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    c_EnemyPosition[5 * i + j] = {ENEMY_CENTER_X + (j - 2) * ENEMY_GAP_X, ENEMY_CENTER_Y + (i - 1) * ENEMY_GAP_Y};
                end
            end

            for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
                c_EnemyBulletPosition[i] = 19'b111_1111_1111_1111_1111;
            end

            c_PlayerPosition = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = 19'b111_1111_1111_1111_1111;
            end

            c_GameState             = GAME_IDLE;
            c_StageState            = 9'b00_0000000;
            c_Score                 = 14'b00_0000_0000_0000;
        end else begin
            // c_fPlayerLeft           = n_fPlayerLeft;
            // c_fPlayerRight          = n_fPlayerRight;
            c_fPlayerShoot          = n_fPlayerShoot;
            c_fGameStartStop        = n_fGameStartStop;

            c_EnemyState            = n_EnemyState;
            c_EnemyBulletState      = n_EnemyBulletState;
            c_PlayerState           = n_PlayerState;
            c_PlayerBulletState     = n_PlayerBulletState;
            
            c_EnemyPosition         = n_EnemyPosition;
            c_EnemyBulletPosition   = n_EnemyBulletPosition;
            c_PlayerPosition        = n_PlayerPosition;
            c_PlayerBulletPosition  = n_PlayerBulletPosition;

            c_GameState             = n_GameState;
            c_StageState            = n_StageState;
            c_Score                 = n_Score;
        end
    end

    always @* begin
        // n_fPlayerLeft       = i_PlayerMoveLeft;
        // n_fPlayerRight      = i_PlayerMoveRight;
        // n_fPlayerShoot      = i_PlayerBulletShoot;
        n_fGameStartStop    = i_GameStartStop;
        
        case (c_GameState)
            GAME_IDLE: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄
                // DONE
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적
                n_fPlayerShoot          = 4'd11;

                n_EnemyState            = 15'b111_1111_1111_1111;
                n_EnemyBulletState      = 31'b000_0000_0000_0000_0000_0000_0000_0000;
                n_PlayerState           = 1'b1;
                n_PlayerBulletState     = 15'b000_0000_0000_0000;

                for (i = 0; i < 3; i = i + 1) begin
                    for (j = 0; j < 5; j = j + 1) begin
                        n_EnemyPosition[5 * i + j] = {ENEMY_CENTER_X + (j - 2) * ENEMY_GAP_X, ENEMY_CENTER_Y + (i - 1) * ENEMY_GAP_Y};
                    end
                end

                for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
                    n_EnemyBulletPosition[i] = 19'b111_1111_1111_1111_1111;
                end

                n_PlayerPosition = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletPosition[i] = 19'b111_1111_1111_1111_1111;
                end

                n_StageState            = 9'b00_0000000;
                n_Score                 = 14'b00_0000_0000_0000;

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

                // 적 이동은 모듈로써 구현(generate block 참고)
                if      (fPlayerShoot)  n_fPlayerShoot = 4'd11;
                else if (~|c_Counter)   n_fPlayerShoot = c_fPlayerShoot;
                else                    n_fPlayerShoot = c_fPlayerShoot - 1;





                if (!(&c_EnemyState))       n_GameState = GAME_VICTORY;
                else if (!c_PlayerState)    n_GameState = GAME_DEFEAT;
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
