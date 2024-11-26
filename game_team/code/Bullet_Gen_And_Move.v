// 수정 중
// i_ => temp_ => o_
module Bullet_Gen_And_Move (
        input i_Clk, i_Rst,
        input i_fPlayerShoot,

    );

    parameter 
        MAX_ENEMY         = 4'd15,
        MAX_ENEMY_BULLET  = 4'd30,
        MAX_PLAYER_BULLET = 4'd16; // 연산 편의 위해 16으로 변경

    parameter
        DISPLAY_VERTICAL   = 640,
        DISPLAY_HORIZONTAL = 480,
        
    parameter
        BULLET_WIDTH    = 6;
        BULLET_HEIGHT   = 20;

    parameter
        DEAD_POSITION   = 19'b111_1111_1111_1111_1111,
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
    reg [3:0]                   c_PlayerBulletCnt,      n_PlayerBulletCnt;      // 몇번째 총알 쏠 차례인지 (0 ~ 15)
    reg [3:0]                   c_PlayerShootCoolDown,  n_PlayerShootCoolDown;  // 쏜지 몇 Tick 지났는지  (0 ~ 11)
    reg                         c_PlayerShootPushed,    n_PlayerShootPushed;

    reg [18:0]                  c_PlayerPosition,       n_PlayerPosition;
    reg [18:0]                  c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    reg [1:0]                   c_Phase,        n_Phase;
    reg [6:0]                   c_PhaseCnt,     n_PhaseCnt;

    // wire
    wire fNextPhase;
    wire fEnemyShootFirst, fEnemyShootSecond;
    wire fPlayerCanShoot, fPlayerShoot;
    wire [MAX_ENEMY_BULLET-1:0]     fEnemyBulletLst;
    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletLst;

    // assign
    assign fNextPhase = &c_PhaseCnt;
    assign fEnemyShootFirst  = fNextPhase & c_EnemyBulletFlag;
    assign fEnemyShootSecond = fNextPhase & ~c_EnemyBulletFlag;
    assign fPlayerCanShoot = ~(|c_PlayerShootCoolDown);
    assign fPlayerShoot = fPlayerCanShoot & c_PlayerShootPushed;

    for (t = 0; t < MAX_ENEMY_BULLET - 1; t = t + 1) begin
        assign fEnemyBulletLst[t] = c_EnemyBulletPosition[t][8:0] == VERTICAL_BORDER;
    end

    for (t = 0; t < MAX_PLAYER_BULLET - 1; t = t + 1) begin
        assign fPlayerBulletLst[t] = ~(|c_EnemyBulletPosition[t][8:0]);
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
            c_PlayerShootCoolDown   = 0;
            c_PlayerShootPushed     = 0;

            c_PlayerPosition        = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

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
            c_PlayerShootCoolDown   = n_PlayerShootCoolDown;
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

        n_PlayerShootCoolDown   = fPlayerShoot ? 4'd11 : {fPlayerCanShoot ? c_PlayerShootCoolDown - 1 : c_PlayerShootCoolDown};
        n_PlayerBulletCnt       = fPlayerShoot ? c_PlayerBulletCnt + 1 : c_PlayerBulletCnt;
        n_EnemyBulletFlag       = fEnemyShoot ? ~c_EnemyBulletFlag : c_EnemyBulletFlag;

        // Enemy Bullet State
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
            n_EnemyBulletState[i] = (i < MAX_ENEMY_BULLET / 2 ? fEnemyShootFirst : fEnemyShootSecond) ?
                1 : c_EnemyBulletState[i] & ~fEnemyBulletLst[i];
        end

        // Enemy Bullet Position
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
            n_EnemyBulletPosition[i] = (i < MAX_ENEMY_BULLET / 2 ? fEnemyShootFirst : fEnemyShootSecond) ? 
                c_EnemyPosition[i] : {c_EnemyBulletState[i] ? 
                    c_EnemyBUlletPosition[i] + 1 : DEAD_POSITION};
        end

        // Player Bullet State
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            n_PlayerBulletState[i] = fPlayerShoot & (i == c_PlayerBulletCnt) ? 1 : {
                c_PlayerBulletState[i] & ~fPlayerBulletLst[i];
            }
        end
        
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            n_PlayerBulletPosition[i] = fPlayerShoot & (i == c_PlayerBulletCnt) ? 
                c_PlayerPosition[i] : {c_PlayerBulletState[i] ? 
                    c_PlayerBulletState[i] & ~fPlayerBulletLst[i] : DEAD_POSITION};
        end
    end

endmodule
