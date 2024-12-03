module VALAGA 
    (
        input   i_Clk, i_Rst,
        input  [3:0] i_Btn,

        output [6:0] o_FND0, o_FND1, o_FND2,
        output [7:0] o_Red, o_Green, o_Blue,
        output o_Clk, o_blank, o_hsync, o_vsync
    );
    
    `include "Parameter.vh" 
  
    integer i, j;
    genvar k, l, m, n, o, p, q, r, s, t, u, v, w, x;

    // ##############################################################
    // reg
    // input
    reg c_fGameStartStop,   n_fGameStartStop;
    
    // Entity
    reg         c_PlayerState,          n_PlayerState;
    reg [18:0]  c_PlayerPos,            n_PlayerPos;
    reg [3:0]   c_PlayerShootCoolDown,  n_PlayerShootCoolDown;
    reg         c_PlayerShootPushed,    n_PlayerShootPushed;

    reg [MAX_PLAYER_BULLET-1:0] c_PlayerBulletState,                        n_PlayerBulletState;
    reg [18:0]                  c_PlayerBulletPos [MAX_PLAYER_BULLET-1:0],  n_PlayerBulletPos [MAX_PLAYER_BULLET-1:0];
    reg [3:0]                   c_PlayerBulletCnt,                          n_PlayerBulletCnt;

    reg [MAX_ENEMY-1:0] c_EnemyState,               n_EnemyState;
    reg [18:0]          c_EnemyPos [MAX_ENEMY-1:0], n_EnemyPos [MAX_ENEMY-1:0];

    reg [MAX_ENEMY_BULLET-1:0]  c_EnemyBulletState,                         n_EnemyBulletState;
    reg [18:0]                  c_EnemyBulletPos   [MAX_ENEMY_BULLET-1:0],  n_EnemyBulletPos   [MAX_ENEMY_BULLET-1:0];
    reg                         c_EnemyBulletFlag,                          n_EnemyBulletFlag;

    // Game
    reg [2:0]   c_GameState,    n_GameState;
    reg [1:0]   c_Phase,        n_Phase;
    reg [6:0]   c_PhaseCnt,     n_PhaseCnt;

    // Display
    reg [9:0]   c_PixelPos_X, n_PixelPos_X;
    reg [9:0]   c_PixelPos_Y, n_PixelPos_Y;

    // ##############################################################
    // wire
    // input
    wire fPlayerMoveLeft, fPlayerMoveRight, fPlayerFire, fGameStartStop;
    
    // Player
    wire fPlayerLeftOutOfBound, fPlayerLightOutOfBound;
    wire fPlayerCanShoot, fPlayerShoot;
    
    wire [9:0] PlayerPos_X;
    wire [8:0] PlayerPos_Y;

    // Bullet
    wire fEnemyShoot;
    wire [MAX_ENEMY_BULLET-1:0]     fEnemyBulletOutOfBound;
    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletOutOfBound;

    // Game
    wire fTick;
    wire fLstPhaseCnt, fNextPhase;
    wire fIdle, fInit, fPlaying, fEnding;
    wire fVictory, fDefeat;

    // Display
    wire hDrawDone, vDrawDone, fDrawDone;
    wire fPixelOnPlayer, fPixelOnPlayerBullet, fPixelOnEnemy, fPixelOnEnemyBullet;
    
    wire [MAX_PLAYER_BULLET-1:0]    fPixelOnPlayerBullet_Each;
    wire [MAX_ENEMY-1:0]            fPixelOnEnemy_Each;
    wire [MAX_ENEMY_BULLET-1:0]     fPixelOnEnemyBullet_Each;

    // Collision
    wire [MAX_ENEMY_BULLET-1:0]  fPlayer_VS_EnemyBullet_Each;
    wire                         fPlayer_VS_EnemyBullet;

    wire [MAX_ENEMY-1:0]         fPlayerBullet_VS_Enemy_Each         [MAX_PLAYER_BULLET-1:0];
    wire [MAX_PLAYER_BULLET-1:0] fPlayerBullet_VS_Enemy;
    wire [MAX_ENEMY_BULLET-1:0]  fPlayerBullet_VS_EnemyBullet_Each   [MAX_PLAYER_BULLET-1:0];
    wire [MAX_PLAYER_BULLET-1:0] fPlayerBullet_VS_EnemyBullet;

    wire [MAX_PLAYER_BULLET-1:0] fEnemy_VS_PlayerBullet_Each         [MAX_ENEMY-1:0];
    wire [MAX_ENEMY-1:0]         fEnemy_VS_PlayerBullet;

    wire [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_Player;
    wire [MAX_PLAYER_BULLET-1:0] fEnemyBullet_VS_PlayerBullet_Each   [MAX_ENEMY_BULLET-1:0];
    wire [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_PlayerBullet;


    wire                         fPlayerCollision;
    wire [MAX_PLAYER_BULLET-1:0] fPlayerBulletCollision;
    wire [MAX_ENEMY-1:0]         fEnemyCollision;
    wire [MAX_ENEMY_BULLET-1:0]  fEnemyBulletCollision;

    // Module
    ClkDiv  clk25m(i_Clk, o_Clk);

    Counter CNT(i_Clk, i_Rst, c_GameState, o_FND0, o_FND1, o_FND2);

    generate
        // Object Detection
        IsinSquare IS0(c_PlayerPos, PLAYER_WIDTH, PLAYER_HEIGHT, c_PixelPos_X, c_PixelPos_Y, fPixelOnPlayer);
            
        for (k = 0; k < MAX_PLAYER_BULLET; k = k + 1) begin :PlayerBulletObjectDetection
            IsinSquare IS1(c_PlayerBulletPos[k], BULLET_WIDTH, BULLET_HEIGHT, c_PixelPos_X, c_PixelPos_Y, fPixelOnPlayerBullet_Each[k]);
        end

        for (l = 0; l < MAX_ENEMY; l = l + 1) begin :EnemyObjectDetection
            IsinSquare IS2(c_EnemyPos[l], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_X, c_PixelPos_Y, fPixelOnEnemy_Each[l]);
        end

        for (m = 0; m < MAX_ENEMY_BULLET; m = m + 1) begin :EnemyBulletObjectDetection
            IsinSquare IS3(c_EnemyBulletPos[m], BULLET_WIDTH, BULLET_HEIGHT, c_PixelPos_X, c_PixelPos_Y, fPixelOnEnemyBullet_Each[m]);
        end

        //Collision
        for (n = 0; n < MAX_ENEMY_BULLET; n = n + 1) begin : PvsEBModuleGen
            CollisionCheck CC0(c_PlayerPos, c_EnemyBulletPos[n], PLAYER_WIDTH, PLAYER_HEIGHT, BULLET_WIDTH, BULLET_HEIGHT, fPlayer_VS_EnemyBullet_Each[n], fEnemyBullet_VS_Player[n]);
        end

        for (o = 0; o < MAX_PLAYER_BULLET; o = o + 1) begin : PBvsEBModuleGenOuter
            for (p = 0; p < MAX_ENEMY_BULLET; p = p + 1) begin : PBvsEBModuleGenInner
                CollisionCheck CC1(c_PlayerBulletPos[o], c_EnemyBulletPos[p], BULLET_WIDTH, BULLET_HEIGHT, BULLET_WIDTH, BULLET_HEIGHT, fPlayerBullet_VS_EnemyBullet_Each[o][p], fEnemyBullet_VS_PlayerBullet_Each[p][o]);
            end

            for (q = 0; q < MAX_ENEMY; q = q + 1) begin : PBvsEModuleGenInner
                CollisionCheck CC1(c_PlayerBulletPos[o], c_EnemyPos[q], BULLET_WIDTH, BULLET_HEIGHT, ENEMY_WIDTH, ENEMY_HEIGHT, fPlayerBullet_VS_Enemy_Each[o][q], fEnemy_VS_PlayerBullet_Each[q][o]);
            end
        end
    endgenerate

    // assign
    // Input
    assign 
        fPlayerMoveLeft         = ~i_Btn[3] & fTick,
        fPlayerMoveRight        = ~i_Btn[2] & fTick,
        fPlayerFire             = ~i_Btn[1],
        fGameStartStop          = ~i_Btn[0] & c_fGameStartStop;

    // Player
    assign 
        fPlayerLeftOutOfBound = ~|c_PlayerPos,
        fPlayerLightOutOfBound = c_PlayerPos == H_DISPLAY - PLAYER_WIDTH;

    assign 
        PlayerPos_X = c_PlayerPos[18:9],
        PlayerPos_Y = c_PlayerPos[ 8:0];

    // Bullet
    assign 
        fPlayerCanShoot = ~(|c_PlayerShootCoolDown),
        fPlayerShoot = fPlayerCanShoot & c_PlayerShootPushed;

    assign fEnemyShoot  = fLstPhaseCnt;
	
    generate
        for (r = 0; r < MAX_PLAYER_BULLET; r = r + 1) begin :PlayerBulletBoundCheck
            assign fPlayerBulletOutOfBound[r] = ~(|c_PlayerBulletPos[r][8:0]);
        end

        for (s = 0; s < MAX_ENEMY_BULLET; s = s + 1) begin :EnemyBulletBoundCheck
            assign fEnemyBulletOutOfBound[s] = c_EnemyBulletPos[s][8:0] == VERTICAL_BORDER;
        end
    endgenerate

    // Game
    assign 
        fTick   = fDrawDone;

    assign
        fIdle       = c_GameState == GAME_IDLE,
        fInit       = c_GameState == GAME_INIT,
        fPlaying    = c_GameState == GAME_PLAYING,
        fEnding     = c_GameState == GAME_DEFEAT | c_GameState == GAME_VICTORY;

    assign 
        fLstPhaseCnt = c_PhaseCnt == MAX_PHASE_CNT,
        fNextPhase   = fLstPhaseCnt;

    assign 
        fVictory    = fPlaying & ~|c_EnemyState,
        fDefeat     = fPlaying & ~c_PlayerState;

    // Display
    assign  
        o_hsync     = c_PixelPos_X < 656 || c_PixelPos_X >= 752,
        o_vsync     = c_PixelPos_Y < 490 || c_PixelPos_Y >= 492,
        o_blank     = ~(c_PixelPos_X >= H_DISPLAY || c_PixelPos_Y >= V_DISPLAY);

    assign
        hDrawDone 	= c_PixelPos_X == H_DISPLAY - 1,
        vDrawDone 	= c_PixelPos_Y == V_DISPLAY - 1,
        fDrawDone  = hDrawDone & vDrawDone;
    
    // ##############################################################
    // Object Detection
    assign 
        fPixelOnPlayerBullet  = |fPixelOnPlayerBullet_Each,
        fPixelOnEnemy         = |fPixelOnEnemy_Each,
        fPixelOnEnemyBullet   = |fPixelOnEnemyBullet_Each;

    assign
        o_Red   = fPixelOnEnemy | fPixelOnEnemyBullet ? 8'b11111111 : 0,
        o_Green = fPixelOnPlayerBullet | fPixelOnEnemyBullet ? 8'b11111111 : 0,
        o_Blue  = fPixelOnPlayer ? 8'b11111111 : 0;

    // Collision
    generate
        for (t = 0; t < MAX_PLAYER_BULLET; t = t + 1) begin: PlayerBulletCollisionEach
            assign fPlayerBullet_VS_Enemy[t] = |fPlayerBullet_VS_Enemy_Each[t];
            assign fPlayerBullet_VS_EnemyBullet[t] = |fPlayerBullet_VS_EnemyBullet_Each[t];
        end

        for (u = 0; u < MAX_ENEMY_BULLET; u = u + 1) begin: EBvsPBasdf
            assign fEnemyBullet_VS_PlayerBullet[u] = |fEnemyBullet_VS_PlayerBullet_Each[u];
        end

        // Final Collision Check
        assign fPlayerCollision = |fPlayer_VS_EnemyBullet_Each;

        for (v = 0; v < MAX_ENEMY; v = v + 1) begin: EnemyBulletCollision
            assign fEnemyCollision[v] = |fEnemy_VS_PlayerBullet_Each[v];
        end

        for (w = 0; w < MAX_PLAYER_BULLET; w = w + 1) begin: PlayerBulletCollision
            assign fPlayerBulletCollision[w] = fPlayerBullet_VS_EnemyBullet[w] | fPlayerBullet_VS_Enemy[w];
        end

        for (x = 0; x < MAX_ENEMY_BULLET; x = x + 1) begin: EnemyBulletCollision
            assign  fEnemyBulletCollision[x] = fEnemyBullet_VS_PlayerBullet[x] | fEnemyBullet_VS_Player[x];
        end
    endgenerate


    // ##############################################################
    always @(negedge i_Rst, posedge i_Clk) begin
        if (~i_Rst) begin
            c_fGameStartStop        = 1;

            c_PlayerState           = 0;
            c_PlayerPos             = {PLAYER_CENTER_X, PLAYER_CENTER_Y};
            c_PlayerShootCoolDown   = 0;
            c_PlayerShootPushed     = 0;
            
            c_PlayerBulletState     = 0;
            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPos[i] = 0;
            end
            c_PlayerBulletCnt       = 0;

            c_EnemyState            = 0;
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyPos[i] = 0;

                c_EnemyBulletPos[i            ]   = 0;
                c_EnemyBulletPos[i + MAX_ENEMY]   = 0;
                c_EnemyBulletState[i            ]      = 0;
                c_EnemyBulletState[i + MAX_ENEMY]      = 0;
            end

            c_EnemyBulletFlag     	 = 0;

            c_GameState             = GAME_IDLE;

            c_Phase                 = 0;
            c_PhaseCnt              = 0;

            c_PixelPos_X = 0;
            c_PixelPos_Y = 0;

        end else begin
            c_fGameStartStop        = n_fGameStartStop;

            c_PlayerState           = n_PlayerState;
            c_PlayerPos        = n_PlayerPos;
            c_PlayerShootCoolDown   = n_PlayerShootCoolDown;
            c_PlayerShootPushed     = n_PlayerShootPushed;
            
            c_PlayerBulletState     = n_PlayerBulletState;
            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPos[i] = n_PlayerBulletPos[i];
            end
            c_PlayerBulletCnt       = n_PlayerBulletCnt;


            c_EnemyState            = n_EnemyState;
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyPos[i] = n_EnemyPos[i];

                c_EnemyBulletState[i]               = n_EnemyBulletState[i];  
                c_EnemyBulletState[i + MAX_ENEMY]   = n_EnemyBulletState[i + MAX_ENEMY]; 
                c_EnemyBulletPos[i]                 = n_EnemyBulletPos[i];
                c_EnemyBulletPos[i + MAX_ENEMY]     = n_EnemyBulletPos[i + MAX_ENEMY];
            end

            c_EnemyBulletFlag       = n_EnemyBulletFlag;

            c_GameState             = n_GameState;

            c_Phase                 = n_Phase;
            c_PhaseCnt              = n_PhaseCnt;
            
            c_PixelPos_X            = n_PixelPos_X;
            c_PixelPos_Y            = n_PixelPos_Y;
        end
    end

    // Display 
    always @(posedge o_Clk) begin
        n_PixelPos_X = c_PixelPos_X == H_TOTAL - 1 ? 0 : c_PixelPos_X + 1;
        n_PixelPos_Y = c_PixelPos_X == H_TOTAL - 1 ? (c_PixelPos_Y == V_TOTAL - 1 ? 0 : c_PixelPos_Y + 1) : c_PixelPos_Y;
    end

    // ##############################################################
    // 
    always @* begin
        n_fGameStartStop        = i_Btn[1];

        n_PlayerState           = c_PlayerState;
        n_PlayerPos             = c_PlayerPos;
        n_PlayerShootCoolDown   = c_PlayerShootCoolDown;
        n_PlayerShootPushed     = c_PlayerShootPushed;


        n_PlayerBulletState     = c_PlayerBulletState;
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            n_PlayerBulletPos[i] = c_PlayerBulletPos[i];
        end
        n_PlayerBulletCnt       = c_PlayerBulletCnt;

        n_EnemyState            = c_EnemyState;
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
            n_EnemyPos[i] = c_EnemyPos[i];

            n_EnemyBulletState[i]               = c_EnemyBulletState[i];  
            n_EnemyBulletState[i + MAX_ENEMY]   = c_EnemyBulletState[i + MAX_ENEMY];
            n_EnemyBulletPos[i]                 = c_EnemyBulletPos[i];
            n_EnemyBulletPos[i + MAX_ENEMY]     = c_EnemyBulletPos[i + MAX_ENEMY];
        end

        n_EnemyBulletFlag       = c_EnemyBulletFlag;

        n_GameState             = c_GameState;

        n_Phase                 = c_Phase;
        n_PhaseCnt              = c_PhaseCnt;

        case (c_GameState)
            GAME_IDLE: begin
                if (fGameStartStop) n_GameState = GAME_INIT;
            end

            GAME_INIT: begin
                n_PlayerState           = 1'b1;
                n_PlayerPos[18:9]  = PLAYER_CENTER_X;
                n_PlayerPos[ 8:0]  = PLAYER_CENTER_Y;

                n_PlayerBulletState     = {MAX_PLAYER_BULLET{1'b0}};
                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletPos[i] = NONE;
                end

                n_EnemyState            = {MAX_ENEMY{1'b1}};
                for (i = 0; i < MAX_ENEMY_COL; i = i + 1) begin
                    for (j = 0; j < MAX_ENEMY_ROW; j = j + 1) begin
                        n_EnemyPos[MAX_ENEMY_ROW * i + j][18:9] = ENEMY_CENTER_X + (j - (MAX_ENEMY_ROW - 1) / 2) * ENEMY_GAP_X;
                        n_EnemyPos[MAX_ENEMY_ROW * i + j][ 8:0] = ENEMY_CENTER_Y + (i - (MAX_ENEMY_COL - 1) / 2) * ENEMY_GAP_Y;
                    end
                end

                for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
                    n_EnemyBulletState[i]   = 0;
                    n_EnemyBulletPos[i]     = NONE;
                end

                n_Phase                 = PHASE_1;
                n_PhaseCnt              = 0;

                n_GameState             = GAME_PLAYING;
            end

            GAME_PLAYING: begin
                n_Phase                 = fTick & fNextPhase ? c_Phase + 1 : c_Phase;
                n_PhaseCnt              = fTick ? (fLstPhaseCnt ? 0 : c_PhaseCnt + 1) : c_PhaseCnt;

                n_PlayerState       = fTick & fPlayerCollision ? 0 : c_PlayerState;
                n_PlayerPos[18:9]   =   (fPlayerMoveLeft  & ~fPlayerLeftOutOfBound)   ? (PlayerPos_X - PLAYER_SPEED) :
                                        (fPlayerMoveRight & ~fPlayerLightOutOfBound)  ? (PlayerPos_X + PLAYER_SPEED) : PlayerPos_X;
                n_PlayerShootCoolDown   = fTick ? (fPlayerShoot ? 4'd11 : {fPlayerCanShoot ? 0 : c_PlayerShootCoolDown - 1}) : c_PlayerShootCoolDown;
                n_PlayerShootPushed     = fTick ? (fPlayerShoot ? 0 : c_PlayerShootPushed | fPlayerFire) : c_PlayerShootPushed; // TODO : Optimization Possible?

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletState[i] = fTick ? (fPlayerShoot & (i == c_PlayerBulletCnt) ? 1 : { c_PlayerBulletState[i] & ~fPlayerBulletOutOfBound[i] & ~fPlayerBulletCollision[i] }) : c_PlayerBulletState[i];
                    n_PlayerBulletPos[i]   = fTick ? (fPlayerShoot & (i == c_PlayerBulletCnt) ? {c_PlayerPos[18:9] + (PLAYER_WIDTH / 2), c_PlayerPos[8:0] - BULLET_HEIGHT} : { c_PlayerBulletState[i] ? c_PlayerBulletPos[i] - PLAYER_BULLET_SPEED : NONE }) : c_PlayerBulletPos[i];
                end
                n_PlayerBulletCnt       = fTick ? (fPlayerShoot ? c_PlayerBulletCnt + 1 : c_PlayerBulletCnt) : c_PlayerBulletCnt;

                for (i = 0; i < MAX_ENEMY_ROW; i = i + 1) begin
                    n_EnemyPos[i   ][18:9] = c_EnemyState[i   ] ? (fTick ? ( (^c_Phase) ? c_EnemyPos[i   ][18:9] + 1 : n_EnemyPos[i   ][18:9] - 1) : c_EnemyPos[i   ][18:9]) : 10'd720;
                    n_EnemyPos[i+ 5][18:9] = c_EnemyState[i+ 5] ? (fTick ? (!(^c_Phase) ? c_EnemyPos[i+ 5][18:9] + 1 : n_EnemyPos[i+ 5][18:9] - 1) : c_EnemyPos[i+ 5][18:9]) : 10'd720;
                    n_EnemyPos[i+10][18:9] = c_EnemyState[i+10] ? (fTick ? ( (^c_Phase) ? c_EnemyPos[i+10][18:9] + 1 : n_EnemyPos[i+10][18:9] - 1) : c_EnemyPos[i+10][18:9]) : 10'd720;

                    n_EnemyPos[i   ][8:0] = c_EnemyState[i   ] ? n_EnemyPos[i   ][8:0] : 9'd500;
                    n_EnemyPos[i+ 5][8:0] = c_EnemyState[i+ 5] ? n_EnemyPos[i+ 5][8:0] : 9'd500;
                    n_EnemyPos[i+10][8:0] = c_EnemyState[i+10] ? n_EnemyPos[i+10][8:0] : 9'd500;
                end

                for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                    n_EnemyState[i] = fTick & fEnemyCollision[i] ? 0 : c_EnemyState[i];

                    n_EnemyBulletState[i]               = fTick ? ((!c_EnemyBulletFlag & fEnemyShoot) ? 1 : c_EnemyBulletState[i            ] & ~fEnemyBulletOutOfBound[i            ]  & ~fEnemyBulletCollision[i            ]) : c_EnemyBulletState[i            ];
                    n_EnemyBulletState[i + MAX_ENEMY]   = fTick ? (( c_EnemyBulletFlag & fEnemyShoot) ? 1 : c_EnemyBulletState[i + MAX_ENEMY] & ~fEnemyBulletOutOfBound[i + MAX_ENEMY]  & ~fEnemyBulletCollision[i + MAX_ENEMY]) : c_EnemyBulletState[i + MAX_ENEMY];
                    n_EnemyBulletPos[i]             = fTick ? ((!c_EnemyBulletFlag & fEnemyShoot) ? {c_EnemyPos[i][18:9] + (ENEMY_WIDTH / 2), c_EnemyPos[i][8:0] + ENEMY_HEIGHT} : { c_EnemyBulletState[i            ] ? c_EnemyBulletPos[i            ] + ENEMY_BULLET_SPEED : NONE }) : c_EnemyBulletPos[i            ];
                    n_EnemyBulletPos[i + MAX_ENEMY] = fTick ? (( c_EnemyBulletFlag & fEnemyShoot) ? {c_EnemyPos[i][18:9] + (ENEMY_WIDTH / 2), c_EnemyPos[i][8:0] + ENEMY_HEIGHT} : { c_EnemyBulletState[i + MAX_ENEMY] ? c_EnemyBulletPos[i + MAX_ENEMY] + ENEMY_BULLET_SPEED : NONE }) : c_EnemyBulletPos[i + MAX_ENEMY];
                end
                n_EnemyBulletFlag       = fTick & fEnemyShoot ? ~c_EnemyBulletFlag : c_EnemyBulletFlag;

                if (~|c_EnemyState)         n_GameState = GAME_VICTORY;
                else if (!c_PlayerState)    n_GameState = GAME_DEFEAT;
                else if (fGameStartStop)    n_GameState = GAME_IDLE;
            end

            GAME_VICTORY: begin
                if (fGameStartStop) n_GameState = GAME_IDLE;
                else                n_GameState = GAME_VICTORY;
            end

            GAME_DEFEAT: begin
                if (fGameStartStop) n_GameState = GAME_IDLE;
                else                n_GameState = GAME_DEFEAT;
            end

        endcase
    end

endmodule
