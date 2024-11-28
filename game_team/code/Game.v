'include "./Parameter.v"    // parameter 외부 참조

module Game 
    (
        input   i_Clk, i_Rst,
        input  [3:0] i_Btn,

        output [6:0] o_FND0, o_FND1, o_FND2,
        output [7:0] o_Red, o_Green, o_Blue,
        output o_Clk, o_blank, o_hsync, o_vsync,
    );

    integer i, j;
    genvar x, y, t, p;

    // ##############################################################
    // reg
    // input
    reg c_fPlayerShoot,     n_fPlayerShoot;     
    reg c_fGameStartStop,   n_fGameStartStop;

    // Entity
    reg [MAX_ENEMY-1:0]             c_EnemyState,                      n_EnemyState;
    reg [MAX_ENEMY_BULLET_SET-1:0]  c_EnemyBulletState[MAX_ENEMY-1:0], n_EnemyBulletState[MAX_ENEMY-1:0];
    reg                             c_EnemyBulletFlag,                 n_EnemyBulletFlag;

    reg [18:0]  c_EnemyPosition         [MAX_ENEMY-1:0],                            n_EnemyPosition         [MAX_ENEMY-1:0];
    reg [18:0]  c_EnemyBulletPosition   [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0],  n_EnemyBulletPosition   [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0];

    reg [3:0]   c_PlayerBulletCnt,      n_PlayerBulletCnt;
    reg [3:0]   c_PlayerShootCoolDown,  n_PlayerShootCoolDown;
    reg         c_PlayerShootPushed,    n_PlayerShootPushed;

    reg                         c_PlayerState,          n_PlayerState;
    reg [MAX_PLAYER_BULLET-1:0] c_PlayerBulletState,    n_PlayerBulletState;
    
    reg [18:0]  c_PlayerPosition,                                   n_PlayerPosition;
    reg [18:0]  c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    // Game
    reg [2:0]   c_GameState,    n_GameState;
    reg [1:0]   c_OnPlayState,  n_OnPlayState;
    reg [3:0]   c_OnPlayCnt,    n_OnPlayCnt;
    reg [1:0]   c_Phase,        n_Phase;
    reg [6:0]   c_PhaseCnt,     n_PhaseCnt;
    reg [9:0]   c_Score,        n_Score;


    // Display
    reg [9:0]   c_PixelPos_X, n_PixelPos_X;
    reg [8:0]   c_PixelPos_Y, n_PixelPos_Y;

    // ##############################################################
    // wire & assign
    // input
    wire fPlayerLeftMove, fPlayerRightMove;   
    wire fPlayerFire, fGameStartStop;

    assign 
        fPlayerLeftMove         = i_Btn[0],
        fPlayerRightMove        = i_Btn[1],
        fPlayerFire             = ~i_PlayerBulletShoot  &  c_fPlayerShoot,
        fGameStartStop          = ~i_GameStartStop      &  c_fGameStartStop;

    // Bullet
    wire fEnemyShoot;
    wire [MAX_ENEMY_BULLET_SET-1:0] fEnemyBulletOutOfBound [MAX_ENEMY-1:0];
    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletOutOfBound;

    wire fPlayerCanShoot, fPlayerShoot;

    for (x = 0; x < MAX_ENEMY_BULLET; x = x + 1) begin
        assign fEnemyBulletOutOfBound[x] = c_EnemyBulletPosition[x][8:0] == VERTICAL_BORDER;
    end

    for (p = 0; p < MAX_PLAYER_BULLET; p = p + 1) begin
        assign fPlayerBulletOutOfBound[p] = ~(|c_PlayerBulletPosition[p][8:0]);
    end

    assign 
        fPlayerCanShoot = ~(|c_PlayerShootCoolDown),
        fPlayerShoot = fPlayerCanShoot & c_PlayerShootPushed;

    // Game
    wire fTick;
    wire fNextPhase;
    wire fIdle, fInit, fPlaying, fEnding;
    wire fOnPlayDraw, fOnPlayMove, fOnPlayCollision, fOnPlayChecking, fOnPlayWaiting, fOnPlayCalcValue;
    wire fVictory, fDefeat;

    assign 
        fTick   = fDrawDone;

    assign
        fIdle       = c_GameState == GAME_IDLE,
        fInit       = c_GameState == GAME_INITIAL,
        fPlaying    = c_GameState == GAME_PLAYING,
        fEnding     = c_GameState == GAME_DEFEAT | c_GameState == GAME_VICTORY;

    assign
        fOnPlayDraw         = c_OnPlayState == ONPLAY_DRAW,
        fOnPlayMove         = c_OnPlayState == ONPLAY_MOVE,
        fOnPlayCollision    = c_OnPlayState == ONPLAY_COLLISION,
        fOnPlayCalcValue    = c_OnPlayState == ONPLAY_CALCVALUE,
        fOnPlayChecking     = c_OnPlayState == ONPLAY_CHECKING,
        fOnPlayWaiting      = c_OnPlayState == ONPLAY_WAITING;

    assign 
        fNextPhase   = c_PhaseCnt == MAX_PHASE_CNT,
        fEnemyShoot  = fNextPhase;

    assign 
        fVictory    = fPlaying & ~|c_EnemyState,
        fDefeat     = fPlaying & ~c_PlayerState;

    // Display
    wire hDrawDone, vDrawDone, fDrawDone;

    assign  
        o_hsync     = r_PixelPos_X < 656 || r_PixelPos_X >= 752,
        o_vsync     = r_PixelPos_Y < 490 || r_PixelPos_Y >= 492,
        o_blank     = ~(hBlank || vBlank);

    assign
        hDrawDone 	= c_PixelPos_X == H_DISPLAY - 1,
        vDrawDone 	= c_PixelPos_Y == V_DISPLAY - 1;
        fDrawDone   = hDrawDone & vDrawDone;

    // Debug
    // TODO : Delete Debug Data
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    wire 
        [9:0] EnemyPosition_X [MAX_ENEMY-1:0],
        [8:0] EnemyPosition_Y [MAX_ENEMY-1:0];

    for (t = 0; t < MAX_ENEMY; t = t + 1) begin
      assign 
        EnemyPosition_X[t] = c_EnemyPosition[t][18:9],
        EnemyPosition_Y[t] = c_EnemyPosition[t][ 8:0];
    end
    
    wire 
        [9:0] PlayerPosition_X,
        [8:0] PlayerPosition_Y;
    
    assign 
        PlayerPosition_X = c_PlayerPosition[18:9],
        PlayerPosition_Y = c_PlayerPosition[ 8:0];
    
    wire [8:0] PlayerBulletPosition_Y;
    
    assign PlayerBulletPosition_Y = c_PlayerBulletPosition[0][ 8:0];
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    // ##############################################################
    // 비동기 입력
    always @(negedge i_Rst, posedge i_Clk) begin
        if (~i_Rst) begin
            c_fPlayerShoot          = 1;
            c_fGameStartStop        = 1;

            c_EnemyState            = 0;
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyPosition[i] = 0;

                for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletPosition[i][j] = 0;
                c_EnemyBulletState[i][j]    = 0;
              end
            end

            c_PlayerState           = 0;
            c_PlayerPosition = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

            c_PlayerBulletState     = 0;
            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = 0;
            end

            c_GameState             = GAME_IDLE;
            c_OnPlayState           = ONPLAY_DRAW;
            c_OnPlayCnt             = 0;
            c_Score                 = 0;

            c_Phase                 = 0;
            c_PhaseCnt              = 0;

            c_PixelPos_X = 0;
            c_PixelPos_Y = 0;

            o_Clk = 0;

        end else begin
            c_fPlayerShoot          = n_fPlayerShoot;
            c_fGameStartStop        = n_fGameStartStop;

            c_EnemyState            = n_EnemyState;
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyPosition[i] = n_EnemyPosition[i];

                for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletPosition[i][j] = n_EnemyBulletPosition[i][j];
                c_EnemyBulletState[i][j]    = n_EnemyBulletState[i][j];
              end
            end
            
            c_PlayerState           = n_PlayerState;
            c_PlayerPosition        = n_PlayerPosition;
            c_PlayerBulletState     = n_PlayerBulletState;
            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = n_PlayerBulletPosition[i];
            end

            c_GameState             = n_GameState;
            c_OnPlayState           = n_OnPlayState;
            c_OnPlayCnt             = n_OnPlayCnt;
            c_Score                 = n_Score;

            c_Phase                 = n_Phase;
            c_PhaseCnt              = n_PhaseCnt;

            o_Clk = ~o_Clk;
        end
    end

    // Display 비동기 입력
    always @(posedge o_Clk) begin
        if (c_PixelPos_X == H_TOTAL - 1) begin
            n_PixelPos_X = 0;

            if (c_PixelPos_Y == V_TOTAL - 1) 
                n_PixelPos_Y = 0;
            else
                n_PixelPos_Y = c_PixelPos_Y + 1;

            end 
        else
            n_PixelPos_X = c_PixelPos_X + 1; 
    end


    // ##############################################################
    // 
    always @* begin
        n_fPlayerShoot          = i_Btn[3];
        n_fGameStartStop        = i_Btn[2];

        n_EnemyState            = c_EnemyState;
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
            n_EnemyPosition[i] = c_EnemyPosition[i];

            for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
            n_EnemyBulletPosition[i][j] = c_EnemyBulletPosition[i][j];
            n_EnemyBulletState[i][j]    = c_EnemyBulletState[i][j];
            end
        end

        n_EnemyBulletFlag       = c_EnemyBulletFlag;

        n_PlayerState           = c_PlayerState;
        n_PlayerPosition        = c_PlayerPosition;
        n_PlayerBulletState     = c_PlayerBulletState;
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            c_PlayerBulletPosition[i] = n_PlayerBulletPosition[i];
        end

        n_PlayerBulletCnt       = c_PlayerBulletCnt;
        n_PlayerShootCoolDown   = n_PlayerShootCoolDown;
        n_PlayerShootPushed     = c_PlayerShootPushed;

        n_GameState             = c_GameState;
        n_OnPlayState           = c_OnPlayState;
        n_OnPlayCnt             = c_OnPlayCnt;
        n_Score                 = c_Score;

        n_Phase                 = c_Phase;
        n_PhaseCnt              = c_PhaseCnt;

        
        case (c_GameState)
            GAME_IDLE: begin
                if (fGameStartStop) n_GameState = GAME_INITIAL;

            end
            GAME_INITIAL: begin
                n_EnemyState            = {MAX_ENEMY{1'b1}};
                n_EnemyBulletState      = {MAX_ENEMY_BULLET{1'b0}};
                

                for (i = 0; i < MAX_ENEMY_COL; i = i + 1) begin
                    for (j = 0; j < MAX_ENEMY_ROW; j = j + 1) begin
                        c_EnemyPosition[MAX_ENEMY_ROW * i + j][18:9] = ENEMY_CENTER_X + (j - (MAX_ENEMY_ROW - 1) / 2) * ENEMY_GAP_X;
                        c_EnemyPosition[MAX_ENEMY_ROW * i + j][ 8:0] = ENEMY_CENTER_Y + (i - (MAX_ENEMY_COL - 1) / 2) * ENEMY_GAP_Y;
                    end
                end

                for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                    for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                        c_EnemyBulletPosition[i][j] = NONE;
                    end
                end

                n_PlayerState           = 1'b1;
                c_PlayerPosition[18:9]  = PLAYER_CENTER_X;
                c_PlayerPosition[ 8:0]  = PLAYER_CENTER_Y;
                n_PlayerBulletState     = {MAX_PLAYER_BULLET{1'b0}};

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    c_PlayerBulletPosition[i] = NONE;
                end

                n_OnPlayState           = ONPLAY_DRAW;
                n_OnPlayCnt             = 0;
                n_Score                 = 0;

                n_Phase                 = PHASE_1;
                n_PhaseCnt              = 0;

                n_GameState             = GAME_PLAYING;

            end
            GAME_PLAYING: begin
                n_Phase                 = fNextPhase ? c_Phase + 1 : c_Phase;


                if (!(&c_EnemyState))       n_GameState = GAME_VICTORY;
                else if (!c_PlayerState)    n_GameState = GAME_DEFEAT;
                else if (fGameStartStop)    n_GameState = GAME_IDLE;
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
