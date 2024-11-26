// 수정 중
// i_ => temp_ => o_
module Bullet_Gen_And_Move (
        input i_Clk, i_Rst,
        input i_fPlayerShoot,

    );

    parameter 
        MAX_ENEMY         = 4'd15,
        MAX_ENEMY_BULLET  = 4'd30,
        MAX_PLAYER_BULLET = 4'd15;

    parameter
        DISPLAY_VERTICAL   = 640,
        DISPLAY_HORIZONTAL = 480,
        
    parameter
        BULLET_WIDTH    = 6;
        BULLET_HEIGHT   = 20;

    parameter
        VERTICAL_BORDER = DISPLAY_VERTICAL - BULLET_HEIGHT;


    integer i, j;
    genvar t;

    // reg
    reg [MAX_ENEMY-1:0]         c_EnemyState,           n_EnemyState;
    reg [MAX_ENEMY_BULLET-1:0]  c_EnemyBulletState,     n_EnemyBulletState;
    reg                         c_EnemyBulletFlag,      n_EnemyBulletFlag;
    
    reg [18:0]                  c_EnemyPosition         [MAX_ENEMY-1:0],            n_EnemyPosition         [MAX_ENEMY-1:0];
    reg [18:0]                  c_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0],     n_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];

    reg                         c_PlayerState,          n_PlayerState;
    reg [MAX_PLAYER_BULLET-1:0] c_PlayerBulletState,    n_PlayerBulletState;
    reg [3:0]                   c_PlayerBulletCnt,      n_PlayerBulletCnt;
    reg [3:0]                   c_PlayerShootCnt,       n_PlayerShootCnt;
    reg                         c_PlayerShootPushed,    n_PlayerShootPushed;

    reg [18:0]                  c_PlayerPosition,       n_PlayerPosition;
    reg [18:0]                  c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    reg [1:0]                   c_Phase,        n_Phase;
    reg [6:0]                   c_PhaseCnt,     n_PhaseCnt;

    // wire
    wire fNextPhase;
    wire fEnemyShootFirst, fEnemyShootSecond;
    wire fPlayerCanShoot;
    wire [MAX_ENEMY_BULLET-1:0]     fEnemyBulletLst;

    // assign
    assign fNextPhase = &c_PhaseCnt;
    assign fEnemyShootFirst  = fNextPhase & c_EnemyBulletFlag;
    assign fEnemyShootSecond = fNextPhase & ~c_EnemyBulletFlag;
    assign fPlayerCanShoot = iPl

    for (t = 0; t < MAX_ENEMY_BULLET - 1; t = t + 1) begin
        assign fEnemyBulletLst[t] = c_ENemyBulletPosition[t][8:0] == VERTICAL_BORDER;
    end


    always @(posedge i_Clk, negedge i_Rst) begin
        if (~i_Rst) begin
            c_EnemyState            = 15'b111_1111_1111_1111;
            c_EnemyBulletState      = 31'b000_0000_0000_0000_0000_0000_0000_0000;
            c_EnemyBulletFlag       = 1'b0;

            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    c_EnemyPosition[5 * i + j] = {ENEMY_CENTER_X + (j - 2) * ENEMY_GAP_X, ENEMY_CENTER_Y + (i - 1) * ENEMY_GAP_Y};
                end
            end

            for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
                c_EnemyBulletPosition[i] = 19'b111_1111_1111_1111_1111;
            end

            c_PlayerState           = 1'b1;
            c_PlayerBulletState     = 15'b000_0000_0000_0000;
            c_PlayerBulletCnt       = 4'b0000;
            c_PlayerShootPushed     = 0;

            c_PlayerPosition = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = 19'b111_1111_1111_1111_1111;
            end

            c_Phase                 = 2'b00;
            c_PhaseCnt              = 7'b000_0000;

        end else begin
            c_EnemyState            = n_EnemyState;
            c_EnemyBulletState      = n_EnemyBulletState;
            c_PlayerState           = n_PlayerState;
            c_PlayerBulletState     = n_PlayerBulletState;
            c_PlayerBulletCnt       = n_PlayerBulletCnt;
            c_PlayerShootPushed     = n_PlayerShootPushed;
            
            c_EnemyPosition         = n_EnemyPosition;
            c_EnemyBulletPosition   = n_EnemyBulletPosition;
            c_PlayerPosition        = n_PlayerPosition;
            c_PlayerBulletPosition  = n_PlayerBulletPosition;
            c_Phase                 = n_Phase;
            c_PhaseCnt              = n_PhaseCnt;
        end
    end

    always @* begin
        n_Phase                 = fNextPhase ? c_Phase + 1 : c_Phase;
        n_PhaseCnt              = c_PhaseCnt + 1;

        n_EnemyState            = c_EnemyState;
        n_PlayerState           = c_PlayerState;
        n_EnemyPosition         = c_EnemyPosition;
        n_PlayerPosition        = c_PlayerPosition;

        n_PlayerBulletCnt       = 
        n_EnemyBulletFlag       = fEnemyShoot ? ~c_EnemyBulletFlag : c_EnemyBulletFlag;

        // Enemy Bullet State
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
            n_EnemyBulletState[i] = (i < MAX_ENEMY_BULLET / 2 ? fEnemyShootFirst : fEnemyShootSecond) ?
                1 : c_EnemyBulletState[i] & ~fEnemyBulletLst[i];
        end

        // Enemy Bullet Position
        for (i = 0; i < MAX_ENEMY_BULLET / 2; i = i + 1) begin
            n_EnemyBulletPosition[i] = (i < MAX_ENEMY_BULLET / 2 ? fEnemyShootFirst : fEnemyShootSecond) ? 
                c_EnemyPosition[i] : {c_EnemyBulletState[i] ? 
                    c_EnemyBUlletPosition[i] + 1 : 19'b111_1111_1111_1111_1111
                };
        end

        // Player Bullet State

        n_PlayerBulletState     = ;

        n_PlayerBulletPosition  = ;


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
        if (~(|i_StageState)) begin                                         // phase가 시작되는 tick에서
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
