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
    genvar x, y, t, e, gen_i, gen_j, gen_k, gen_x, gen_y, gen_z, ii, jj, k, l, m, n, o, p;
    
    ClkDiv  clk25m(i_Clk, o_Clk);

    Game_FND GFND(i_Clk, i_Rst, c_GameState, o_FND0, o_FND1, o_FND2);


    // ##############################################################
    // reg
    // input
    reg c_fPlayerShoot,     n_fPlayerShoot;     
    reg c_fGameStartStop,   n_fGameStartStop;
    
    // Entity
    reg [MAX_ENEMY-1:0]         c_EnemyState,       n_EnemyState;
    reg [MAX_ENEMY_BULLET-1:0]  c_EnemyBulletState, n_EnemyBulletState;
                
    reg [18:0]  c_EnemyPosition         [MAX_ENEMY-1:0],        n_EnemyPosition         [MAX_ENEMY-1:0];
    reg [18:0]  c_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], n_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];
    reg         c_EnemyBulletFlag,                              n_EnemyBulletFlag;
                
    reg [3:0]   c_PlayerBulletCnt,      n_PlayerBulletCnt;
    reg [3:0]   c_PlayerShootCoolDown,  n_PlayerShootCoolDown;
    reg         c_PlayerShootPushed,    n_PlayerShootPushed;

    reg                         c_PlayerState,          n_PlayerState;
    reg [MAX_PLAYER_BULLET-1:0] c_PlayerBulletState,    n_PlayerBulletState;
    
    reg [18:0]  c_PlayerPosition,                                   n_PlayerPosition;
    reg [18:0]  c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

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
    wire fPlayerLeftMove, fPlayerRightMove;   
    wire fPlayerFire, fGameStartStop;
    
    // Player
    wire fPlayerLeftTouch, fPlayerRightTouch;
    
    wire [9:0] PlayerPosition_X;
    wire [8:0] PlayerPosition_Y;
    
    // Bullet
    wire fEnemyShoot;
    wire [MAX_ENEMY_BULLET-1:0]     fEnemyBulletOutOfBound;
    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletOutOfBound;

    wire fPlayerCanShoot, fPlayerShoot;

    // Game
    wire fTick;
    wire fLstPhaseCnt, fNextPhase;
    wire fIdle, fInit, fPlaying, fEnding;
    wire fVictory, fDefeat;

    // Display
    wire hDrawDone, vDrawDone, fDrawDone;
    wire fPlayerPixel, fPlayerBulletPixel, fEnemyPixel, fEnemyBulletPixel;

    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletPixel_Each;
    wire [MAX_ENEMY-1:0]            fEnemyPixel_Each;
    wire [MAX_ENEMY_BULLET-1:0]     fEnemyBulletPixel_Each;

    // ##############################################################
    // function
    // Display
    function is_in_range(
            input [18:0] i_Pos,
            input [5:0] i_obj_W, i_obj_H, 
            input [9:0] i_n_pixel_x, i_n_pixel_y
        );

        reg [9:0] obj_X;
		  reg [8:0] obj_Y;
        reg horizontalRange, verticalRange;
        
        begin
            obj_X = i_Pos[18:9];
            obj_Y = i_Pos[8:0];
            horizontalRange = (i_n_pixel_x >= obj_X) & (i_n_pixel_x < obj_X + i_obj_W);
            verticalRange   = (i_n_pixel_y >= obj_Y) & (i_n_pixel_y < obj_Y + i_obj_H);
            is_in_range     = horizontalRange & verticalRange;
        end
    endfunction

    // ##############################################################
    // assign
    assign 
        fPlayerLeftMove         = ~i_Btn[3],
        fPlayerRightMove        = ~i_Btn[2],
        fPlayerFire             = ~i_Btn[1] & c_fPlayerShoot,
        fGameStartStop          = ~i_Btn[0] & c_fGameStartStop;

    // Player
    assign fPlayerLeftTouch = ~|c_PlayerPosition;
    assign fPlayerRightTouch = c_PlayerPosition == H_DISPLAY - PLAYER_WIDTH;

    assign 
        PlayerPosition_X = c_PlayerPosition[18:9],
        PlayerPosition_Y = c_PlayerPosition[ 8:0];

    // Bullet
    assign fEnemyShoot  = fLstPhaseCnt;
	 
    generate
        for (x = 0; x < MAX_ENEMY_BULLET; x = x + 1) begin :EnemyBulletBoundCheck
            assign fEnemyBulletOutOfBound[x] = c_EnemyBulletPosition[x][8:0] == VERTICAL_BORDER;
        end

        for (e = 0; e < MAX_PLAYER_BULLET; e = e + 1) begin :PlayerBulletBoundCheck
            assign fPlayerBulletOutOfBound[e] = ~(|c_PlayerBulletPosition[e][8:0]);
        end
    endgenerate

    assign 
        fPlayerCanShoot = ~(|c_PlayerShootCoolDown),
        fPlayerShoot = fPlayerCanShoot & c_PlayerShootPushed;

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
    generate
        assign fPlayerPixel = is_in_range(c_PlayerPosition, PLAYER_WIDTH, PLAYER_HEIGHT, c_PixelPos_X, c_PixelPos_Y);
            
        for (gen_i = 0; gen_i < MAX_PLAYER_BULLET; gen_i = gen_i + 1) begin :PlayerBulletObjectDetection
            assign fPlayerBulletPixel_Each[gen_i]   = is_in_range(
                                                        c_PlayerBulletPosition[gen_i],
                                                        BULLET_WIDTH, 
                                                        BULLET_HEIGHT, 
                                                        c_PixelPos_X, 
                                                        c_PixelPos_Y
                                                    );
        end
        assign fPlayerBulletPixel   = |fPlayerBulletPixel_Each;

        for (gen_j = 0; gen_j < MAX_ENEMY; gen_j = gen_j + 1) begin :EnemyObjectDetection
            assign fEnemyPixel_Each[gen_j]          = is_in_range(
                                                        c_EnemyPosition[gen_j], 
                                                        ENEMY_WIDTH, 
                                                        ENEMY_HEIGHT, 
                                                        c_PixelPos_X, 
                                                        c_PixelPos_Y
                                                    );
        end
        assign fEnemyPixel          = |fEnemyPixel_Each;

        for (gen_k = 0; gen_k < MAX_ENEMY_BULLET; gen_k = gen_k + 1) begin :EnemyBulletObjectDetection
            assign fEnemyBulletPixel_Each[gen_k]    =   is_in_range(
                                                            c_EnemyBulletPosition[gen_k], 
                                                            BULLET_WIDTH, 
                                                            BULLET_HEIGHT, 
                                                            c_PixelPos_X, 
                                                            c_PixelPos_Y
                                                        );
        end
        assign fEnemyBulletPixel = |fEnemyBulletPixel_Each;
    endgenerate

    assign
        o_Red   = fEnemyPixel | fEnemyBulletPixel ? 8'b11111111 : 0,
        o_Green = fPlayerBulletPixel | fEnemyBulletPixel ? 8'b11111111 : 0,
        o_Blue  = fPlayerPixel ? 8'b11111111 : 0;

    // ##############################################################
    // Collision
    wire    [MAX_PLAYER_BULLET-1:0] fEnemyBullet_VS_PlayerBullet_Each   [MAX_ENEMY_BULLET-1:0];
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_PlayerBullet;
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_Player;
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBulletCollision;

    wire    [MAX_ENEMY_BULLET-1:0]  fPlayerBullet_VS_EnemyBullet_Each   [MAX_PLAYER_BULLET-1:0];
    wire    [MAX_PLAYER_BULLET-1:0] fPlayerBullet_VS_EnemyBullet;
    wire    [MAX_ENEMY-1:0]         fPlayerBullet_VS_Enemy_Each         [MAX_PLAYER_BULLET-1:0];
    wire    [MAX_PLAYER_BULLET-1:0] fPlayerBullet_VS_Enemy;
    wire    [MAX_PLAYER_BULLET-1:0] fPlayerBulletCollision;

    wire    [MAX_PLAYER_BULLET-1:0] fEnemy_VS_PlayerBullet_Each         [MAX_ENEMY-1:0];
    wire    [MAX_ENEMY-1:0]         fEnemy_VS_PlayerBullet;
    wire    [MAX_ENEMY-1:0]         fEnemyCollision;

    wire    [MAX_ENEMY_BULLET-1:0]  fPlayer_VS_EnemyBullet_Each;
    wire                            fPlayer_VS_EnemyBullet;
    wire                            fPlayerCollision;

    genvar dont, make, me, angry, anymore;
    
    generate
        for (dont = 0; dont < MAX_ENEMY_BULLET; dont = dont + 1) begin : PvsEBModuleGen
            CollisionCheck CC0(c_PlayerPosition, c_EnemyBulletPosition[dont], PLAYER_WIDTH, PLAYER_HEIGHT, BULLET_WIDTH, BULLET_HEIGHT, fPlayer_VS_EnemyBullet_Each[dont], fEnemyBullet_VS_Player[dont]);
        end

        for (make = 0; make < MAX_PLAYER_BULLET; make = make + 1) begin : PBvsEBModuleGenOuter
            for (me = 0; me < MAX_ENEMY_BULLET; me = me + 1) begin : PBvsEBModuleGenInner
                CollisionCheck CC1(c_PlayerBulletPosition[make], c_EnemyBulletPosition[me], BULLET_WIDTH, BULLET_HEIGHT, BULLET_WIDTH, BULLET_HEIGHT, fPlayerBullet_VS_EnemyBullet_Each[make][me], fEnemyBullet_VS_PlayerBullet_Each[me][make]);
            end

            assign fPlayerBullet_VS_EnemyBullet[make] = |fPlayerBullet_VS_EnemyBullet_Each[make];

            for (anymore = 0; anymore < MAX_ENEMY; anymore = anymore + 1) begin : PBvsEModuleGenInner
                CollisionCheck CC1(c_PlayerBulletPosition[angry], c_EnemyPosition[anymore], BULLET_WIDTH, BULLET_HEIGHT, ENEMY_WIDTH, ENEMY_HEIGHT, fPlayerBullet_VS_Enemy_Each[angry][anymore], fEnemy_VS_PlayerBullet_Each[anymore][angry]);
            end

            assign fPlayerBullet_VS_Enemy[angry] = |fPlayerBullet_VS_Enemy_Each[angry];
        end

        for (ii = 0; ii < MAX_ENEMY_BULLET; ii = ii + 1) begin: EBvsPBasdf
            assign fEnemyBullet_VS_PlayerBullet[ii] = |fEnemyBullet_VS_PlayerBullet_Each[ii];
        end


        // Final Collision Check
        assign fPlayerCollision = |fPlayer_VS_EnemyBullet_Each;

        for (jj = 0; jj < MAX_ENEMY; jj = jj + 1) begin: EnemyBulletCollision
            assign fEnemyCollision[jj] = |fEnemy_VS_PlayerBullet_Each[jj];
        end

        for (k = 0; k < MAX_PLAYER_BULLET; k = k + 1) begin: PlayerBulletCollision
            assign fPlayerBulletCollision[k] = fPlayerBullet_VS_EnemyBullet[k] | fPlayerBullet_VS_Enemy[k];
        end

        for (n = 0; n < MAX_ENEMY_BULLET; n = n + 1) begin: EnemyBulletCollision
            assign  fEnemyBulletCollision[n] = fEnemyBullet_VS_PlayerBullet[n] | fEnemyBullet_VS_Player[n];
        end
    endgenerate

    // ##############################################################
    always @(negedge i_Rst, posedge i_Clk) begin
        if (~i_Rst) begin
            c_fPlayerShoot          = 1;
            c_fGameStartStop        = 1;

            c_EnemyState            = 0;
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyPosition[i] = 0;

                c_EnemyBulletPosition[i            ]   = 0;
                c_EnemyBulletPosition[i + MAX_ENEMY]   = 0;
                c_EnemyBulletState[i            ]      = 0;
                c_EnemyBulletState[i + MAX_ENEMY]      = 0;
            end
            c_EnemyBulletFlag     	 = 0;

            c_PlayerState           = 0;
            c_PlayerPosition = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

            c_PlayerBulletState     = 0;
            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = 0;
            end

            c_PlayerShootCoolDown   = 0;
            c_PlayerShootPushed     = 0;
            c_PlayerBulletCnt       = 0;

            c_GameState             = GAME_IDLE;

            c_Phase                 = 0;
            c_PhaseCnt              = 0;

            c_PixelPos_X = 0;
            c_PixelPos_Y = 0;

        end else begin
            c_fPlayerShoot          = n_fPlayerShoot;
            c_fGameStartStop        = n_fGameStartStop;

            c_EnemyState            = n_EnemyState;
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyPosition[i] = n_EnemyPosition[i];

                c_EnemyBulletPosition[i            ]   = n_EnemyBulletPosition[i            ];
                c_EnemyBulletPosition[i + MAX_ENEMY]   = n_EnemyBulletPosition[i + MAX_ENEMY];
                c_EnemyBulletState[i            ]      = n_EnemyBulletState[i            ];  
                c_EnemyBulletState[i + MAX_ENEMY]      = n_EnemyBulletState[i + MAX_ENEMY];  
            end

            c_EnemyBulletFlag       = n_EnemyBulletFlag;

            c_PlayerState           = n_PlayerState;
            c_PlayerPosition        = n_PlayerPosition;
            c_PlayerBulletState     = n_PlayerBulletState;
            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = n_PlayerBulletPosition[i];
            end

            c_PlayerShootCoolDown   = n_PlayerShootCoolDown;
            c_PlayerShootPushed     = n_PlayerShootPushed;
            c_PlayerBulletCnt       = n_PlayerBulletCnt;

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
        n_fPlayerShoot          = i_Btn[0];
        n_fGameStartStop        = i_Btn[1];

        n_EnemyState            = c_EnemyState;
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
            n_EnemyPosition[i] = c_EnemyPosition[i];

            n_EnemyBulletPosition[i            ]   = c_EnemyBulletPosition[i            ];
            n_EnemyBulletPosition[i + MAX_ENEMY]   = c_EnemyBulletPosition[i + MAX_ENEMY];
            n_EnemyBulletState[i            ]      = c_EnemyBulletState[i            ];  
            n_EnemyBulletState[i + MAX_ENEMY]      = c_EnemyBulletState[i + MAX_ENEMY]; 
        end

        n_EnemyBulletFlag       = c_EnemyBulletFlag;

        n_PlayerState           = c_PlayerState;
        n_PlayerPosition        = c_PlayerPosition;
        n_PlayerBulletState     = c_PlayerBulletState;
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            n_PlayerBulletPosition[i] = c_PlayerBulletPosition[i];
        end

        n_PlayerBulletCnt       = c_PlayerBulletCnt;
        n_PlayerShootCoolDown   = c_PlayerShootCoolDown;
        n_PlayerShootPushed     = c_PlayerShootPushed;

        n_GameState             = c_GameState;

        n_Phase                 = c_Phase;
        n_PhaseCnt              = c_PhaseCnt;

        
        case (c_GameState)
            GAME_IDLE: begin
                if (fGameStartStop) n_GameState = GAME_INIT;
            end

            GAME_INIT: begin
                n_EnemyState            = {MAX_ENEMY{1'b1}};
                
                for (i = 0; i < MAX_ENEMY_COL; i = i + 1) begin
                    for (j = 0; j < MAX_ENEMY_ROW; j = j + 1) begin
                        n_EnemyPosition[MAX_ENEMY_ROW * i + j][18:9] = ENEMY_CENTER_X + (j - (MAX_ENEMY_ROW - 1) / 2) * ENEMY_GAP_X;
                        n_EnemyPosition[MAX_ENEMY_ROW * i + j][ 8:0] = ENEMY_CENTER_Y + (i - (MAX_ENEMY_COL - 1) / 2) * ENEMY_GAP_Y;
                    end
                end

                for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
                    n_EnemyBulletPosition[i] = NONE;
                    n_EnemyBulletState[i]    = 0;
                end

                n_PlayerState           = 1'b1;
                n_PlayerPosition[18:9]  = PLAYER_CENTER_X;
                n_PlayerPosition[ 8:0]  = PLAYER_CENTER_Y;
                n_PlayerBulletState     = {MAX_PLAYER_BULLET{1'b0}};

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletPosition[i] = NONE;
                end

                n_Phase                 = PHASE_1;
                n_PhaseCnt              = 0;

                n_GameState             = GAME_PLAYING;
            end

            GAME_PLAYING: begin
                // Calculate Value
                n_Phase                 = fTick & fNextPhase ? c_Phase + 1 : c_Phase;
                n_PhaseCnt              = fTick ? (fLstPhaseCnt ? 0 : c_PhaseCnt + 1) : c_PhaseCnt;

                n_EnemyBulletFlag       = fTick & fEnemyShoot ? ~c_EnemyBulletFlag : c_EnemyBulletFlag;

                n_PlayerShootCoolDown   = fTick ? (fPlayerShoot ? 4'd11 : {fPlayerCanShoot ? 0 : c_PlayerShootCoolDown - 1}) : c_PlayerShootCoolDown;
                n_PlayerShootPushed     = fTick ? (fPlayerShoot ? 0 : c_PlayerShootPushed | ~i_Btn[1]) : c_PlayerShootPushed;
                n_PlayerBulletCnt       = fTick ? (fPlayerShoot ? c_PlayerBulletCnt + 1 : c_PlayerBulletCnt) : c_PlayerBulletCnt;

                // Moving
                for (i = 0; i < MAX_ENEMY_ROW; i = i + 1) begin
                    n_EnemyPosition[i   ][18:9] = c_EnemyState[i   ] ? (fTick ? ( (^c_Phase) ? c_EnemyPosition[i   ][18:9] + 1 : n_EnemyPosition[i   ][18:9] - 1) : c_EnemyPosition[i   ][18:9]) : 10'd720;
                    n_EnemyPosition[i+ 5][18:9] = c_EnemyState[i+ 5] ? (fTick ? (!(^c_Phase) ? c_EnemyPosition[i+ 5][18:9] + 1 : n_EnemyPosition[i+ 5][18:9] - 1) : c_EnemyPosition[i+ 5][18:9]) : 10'd720;
                    n_EnemyPosition[i+10][18:9] = c_EnemyState[i+10] ? (fTick ? ( (^c_Phase) ? c_EnemyPosition[i+10][18:9] + 1 : n_EnemyPosition[i+10][18:9] - 1) : c_EnemyPosition[i+10][18:9]) : 10'd720;

                    n_EnemyPosition[i   ][8:0] = c_EnemyState[i   ] ? n_EnemyPosition[i   ][8:0] : 9'd500;
                    n_EnemyPosition[i+ 5][8:0] = c_EnemyState[i+ 5] ? n_EnemyPosition[i+ 5][8:0] : 9'd500;
                    n_EnemyPosition[i+10][8:0] = c_EnemyState[i+10] ? n_EnemyPosition[i+10][8:0] : 9'd500;
                end

                for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                    n_EnemyState[i] = fTick & fEnemyCollision[i] ? 0 : c_EnemyState[i];

                    n_EnemyBulletPosition[i            ] = fTick ? ((!c_EnemyBulletFlag & fEnemyShoot) ? {c_EnemyPosition[i][18:9] + (ENEMY_WIDTH / 2), c_EnemyPosition[i][8:0] + ENEMY_HEIGHT} : { c_EnemyBulletState[i            ] ? c_EnemyBulletPosition[i            ] + ENEMY_BULLET_SPEED : NONE }) : c_EnemyBulletPosition[i            ];
                    n_EnemyBulletPosition[i + MAX_ENEMY] = fTick ? (( c_EnemyBulletFlag & fEnemyShoot) ? {c_EnemyPosition[i][18:9] + (ENEMY_WIDTH / 2), c_EnemyPosition[i][8:0] + ENEMY_HEIGHT} : { c_EnemyBulletState[i + MAX_ENEMY] ? c_EnemyBulletPosition[i + MAX_ENEMY] + ENEMY_BULLET_SPEED : NONE }) : c_EnemyBulletPosition[i + MAX_ENEMY];
                end

                n_PlayerPosition[18:9] = 
                    (fTick & fPlayerLeftMove  & ~fPlayerLeftTouch)   ? (PlayerPosition_X - PLAYER_SPEED) :
                    (fTick & fPlayerRightMove & ~fPlayerRightTouch)  ? (PlayerPosition_X + PLAYER_SPEED) : PlayerPosition_X;

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletPosition[i]   = fTick ? (fPlayerShoot & (i == c_PlayerBulletCnt) ? {c_PlayerPosition[18:9] + (PLAYER_WIDTH / 2), c_PlayerPosition[8:0] - BULLET_HEIGHT} : { c_PlayerBulletState[i] ? c_PlayerBulletPosition[i] - PLAYER_BULLET_SPEED : NONE }) : c_PlayerBulletPosition[i];
                end



                n_PlayerState = fTick & fPlayerCollision ? 0 : c_PlayerState;
                
                // Collision Check
                for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                    n_EnemyBulletState[i            ] = fTick ? ((!c_EnemyBulletFlag & fEnemyShoot) ? 1 : c_EnemyBulletState[i            ] & ~fEnemyBulletOutOfBound[i            ]  & ~fEnemyBulletCollision[i            ]) : c_EnemyBulletState[i            ];
                    n_EnemyBulletState[i + MAX_ENEMY] = fTick ? (( c_EnemyBulletFlag & fEnemyShoot) ? 1 : c_EnemyBulletState[i + MAX_ENEMY] & ~fEnemyBulletOutOfBound[i + MAX_ENEMY]  & ~fEnemyBulletCollision[i + MAX_ENEMY]) : c_EnemyBulletState[i + MAX_ENEMY];
                end

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletState[i] =  fTick ? (fPlayerShoot & (i == c_PlayerBulletCnt) ? 1 : { c_PlayerBulletState[i] & ~fPlayerBulletOutOfBound[i] & ~fPlayerBulletCollision[i] }) : c_PlayerBulletState[i];
                end

                // Monitor

                // Game Over Check

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
