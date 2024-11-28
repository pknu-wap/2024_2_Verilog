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
    reg [2:0]   c_OnPlayState,  n_OnPlayState;
    reg [3:0]   c_OnPlayCnt,    n_OnPlayCnt;
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
    wire [MAX_ENEMY_BULLET_SET-1:0] fEnemyBulletOutOfBound [MAX_ENEMY-1:0];
    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletOutOfBound;

    wire fPlayerCanShoot, fPlayerShoot;

    // Game
    wire fTick;
    wire fLstPhaseCnt, fNextPhase;
    wire fIdle, fInit, fPlaying, fEnding;
    wire fOnPlayMove, fOnPlayCollision, fOnPlayChecking, fOnPlayWaiting, fOnPlayCalcValue;
    wire fVictory, fDefeat;

    // Display
    wire hDrawDone, vDrawDone, fDrawDone;
    wire fPlayerPixel, fPlayerBulletPixel, fEnemyPixel, fEnemyBulletPixel;
    wire pixelState;

    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletPixel_Each;
    wire [MAX_ENEMY-1:0]            fEnemyPixel_Each;
    wire [MAX_ENEMY_BULLET_SET-1:0] fEnemyBulletPixel_Each [MAX_ENEMY-1:0];

    // ##############################################################
    // function
    // Display
    function is_in_range(
            input [9:0] i_obj_x, i_obj_y, 
            input [9:0] i_obj_width, i_obj_height, 
            input [9:0] i_n_pixel_x, i_n_pixel_y
        );

        reg horizontalRange, verticalRange;
        
        begin
            horizontalRange = (i_n_pixel_x >= i_obj_x) & (i_n_pixel_x < i_obj_x + i_obj_width);
            verticalRange   = (i_n_pixel_y >= i_obj_y) & (i_n_pixel_y < i_obj_y + i_obj_height);
            is_in_range     = horizontalRange & verticalRange;
        end
    endfunction

    // Collision
    function IsCollision
        (
            input   [18:0]  i_APosition, 
            input   [18:0]  i_BPosition, 
            input   [9:0]   i_AWidth, 
            input   [8:0]   i_AHeight, 
            input   [9:0]   i_BWidth, 
            input   [8:0]   i_BHeight
        );

        reg         horizontalCollision;
        reg         verticalCollision;
        reg [9:0]   Ax1, Ax2, Bx1, Bx2;
        reg [8:0]   Ay1, Ay2, By1, By2;

        begin
            {Ax1, Ay1}          = i_APosition;
            {Bx1, By1}          = i_BPosition;
            {Ax2, Ay2}          = {Ax1 + i_AWidth, Ay1 + i_AHeight};
            {Bx2, By2}          = {Bx1 + i_BWidth, By1 + i_BHeight};

            horizontalCollision = ~((Ax2 <= Bx1) | (Ax1 >= Bx2));
            verticalCollision   = ~((Ay2 <= By1) | (Ay1 >= By2));
            
            IsCollision         = horizontalCollision & verticalCollision;
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
    //assign fEnemyShoot  = fLstPhaseCnt & fOnPlayCollision | fLstPhaseCnt & fOnPlayMove;
	 
    generate
        for (x = 0; x < MAX_ENEMY_BULLET; x = x + 1) begin :EnemyBulletBoundCheck
            assign fEnemyBulletOutOfBound[x][0] = c_EnemyBulletPosition[x][0][8:0] == VERTICAL_BORDER;
            assign fEnemyBulletOutOfBound[x][1] = c_EnemyBulletPosition[x][1][8:0] == VERTICAL_BORDER;
        end
    endgenerate

    generate
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
        fOnPlayWaiting      = c_OnPlayState == ONPLAY_WAITING,
        fOnPlayCalcValue    = c_OnPlayState == ONPLAY_CALCVALUE,
        fOnPlayMove         = c_OnPlayState == ONPLAY_MOVE,
        fOnPlayCollision    = c_OnPlayState == ONPLAY_COLLISION,
        fOnPlayChecking     = c_OnPlayState == ONPLAY_CHECKING;

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
    
    assign pixelState = fPlayerPixel         ? 3'b001 :
                        fPlayerBulletPixel   ? 3'b010 :
                        fEnemyBulletPixel    ? 3'b100 :
                        fEnemyPixel          ? 3'b011 : 3'b000;
    
    // ##############################################################
    // Object Detection
    assign fPlayerPixel = is_in_range(PlayerPosition_X, {1'b0, PlayerPosition_Y}, PLAYER_WIDTH, {1'b0, PLAYER_HEIGHT}, c_PixelPos_X, c_PixelPos_Y);

    generate
        for (gen_i = 0; gen_i < MAX_PLAYER_BULLET; gen_i = gen_i + 1) begin :PlayerBulletObjectDetection
            assign fPlayerBulletPixel_Each[gen_i]   = is_in_range(
                                                        c_PlayerBulletPosition[gen_i][18:9], 
                                                        {1'b0, c_PlayerBulletPosition[gen_i][8:0]},
                                                        BULLET_WIDTH, 
                                                        {1'b0, BULLET_HEIGHT}, 
                                                        c_PixelPos_X, 
                                                        c_PixelPos_Y
                                                    );
        end
    endgenerate
    assign fPlayerBulletPixel   = |fPlayerBulletPixel_Each;

    generate
        for (gen_j = 0; gen_j < MAX_ENEMY; gen_j = gen_j + 1) begin :EnemyObjectDetection
            assign fEnemyPixel_Each[gen_j]          = is_in_range(
                                                        c_EnemyPosition[gen_j][18:9], 
                                                        {1'b0, c_EnemyPosition[gen_j][8:0]}, 
                                                        ENEMY_WIDTH, 
                                                        {1'b0, ENEMY_HEIGHT}, 
                                                        c_PixelPos_X, 
                                                        c_PixelPos_Y
                                                    );
        end
    endgenerate
    assign fEnemyPixel          = |fEnemyPixel_Each;

    generate
        for (gen_k = 0; gen_k < MAX_ENEMY; gen_k = gen_k + 1) begin :EnemyBulletObjectDetectionOuter
            for (gen_x = 0; gen_x < MAX_ENEMY_BULLET_SET; gen_x = gen_x + 1) begin :EnemyBulletObjectDetectionInner
                assign fEnemyBulletPixel_Each[gen_k][gen_x]    = is_in_range(
                                                                    c_EnemyBulletPosition[gen_k][gen_x][18:9], 
                                                                    {1'b0, c_EnemyBulletPosition[gen_k][gen_x][8:0]}, 
                                                                    BULLET_WIDTH, 
                                                                    {1'b0, BULLET_HEIGHT}, 
                                                                    c_PixelPos_X, 
                                                                    c_PixelPos_Y
                                                                );
            end
        end
    endgenerate
    assign fEnemyBulletPixel = 
        |fEnemyBulletPixel_Each[ 0] |
        |fEnemyBulletPixel_Each[ 1] |
        |fEnemyBulletPixel_Each[ 2] |
        |fEnemyBulletPixel_Each[ 3] |
        |fEnemyBulletPixel_Each[ 4] |
        |fEnemyBulletPixel_Each[ 5] |
        |fEnemyBulletPixel_Each[ 6] |
        |fEnemyBulletPixel_Each[ 7] |
        |fEnemyBulletPixel_Each[ 8] |
        |fEnemyBulletPixel_Each[ 9] |
        |fEnemyBulletPixel_Each[10] |
        |fEnemyBulletPixel_Each[11] |
        |fEnemyBulletPixel_Each[12] |
        |fEnemyBulletPixel_Each[13] |
        |fEnemyBulletPixel_Each[14];

    assign
        o_Red   = fEnemyPixel ? 8'b11111111 : 0,
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

    for (ii = 0; ii < MAX_ENEMY_BULLET; ii = ii + 1) begin
        for (jj = 0; jj < MAX_PLAYER_BULLET; jj = jj + 1) begin
            assign  fEnemyBullet_VS_PlayerBullet_Each[ii][jj] = IsCollision(
                                                                c_EnemyBulletPosition[ii], 
                                                                c_PlayerBulletPosition[jj], 
                                                                BULLET_WIDTH, 
                                                                BULLET_HEIGHT, 
                                                                BULLET_WIDTH, 
                                                                BULLET_HEIGHT
                                                            ) ? 1'b1 : 1'b0;
        end
        assign  fEnemyBullet_VS_PlayerBullet[ii]    = |fEnemyBullet_VS_PlayerBullet_Each[ii] ? 1'b1 : 1'b0;
        assign  fEnemyBullet_VS_Player[ii]          = IsCollision(
                                                        c_EnemyBulletPosition[ii], 
                                                        {c_PlayerPosition, PLAYER_CENTER_Y}, 
                                                        BULLET_WIDTH, 
                                                        BULLET_HEIGHT, 
                                                        PLAYER_WIDTH, 
                                                        PLAYER_HEIGHT
                                                    ) ? 1'b1 : 1'b0;
        assign  fEnemyBulletCollision[ii]           = fEnemyBullet_VS_PlayerBullet[ii] | fEnemyBullet_VS_Player[ii];
    end

    for (k = 0; k < MAX_PLAYER_BULLET; k = k + 1) begin
        for (l = 0; l < MAX_ENEMY_BULLET; l = l + 1) begin
            assign  fPlayerBullet_VS_EnemyBullet_Each[k][l] = IsCollision(
                                                                c_PlayerBulletPosition[k], 
                                                                c_EnemyBulletPosition[l], 
                                                                BULLET_WIDTH, 
                                                                BULLET_HEIGHT, 
                                                                BULLET_WIDTH, 
                                                                BULLET_HEIGHT
                                                            ) ? 1'b1 : 1'b0;
        end
        assign  fPlayerBullet_VS_EnemyBullet[k]     = |fPlayerBullet_VS_EnemyBullet_Each[k] ? 1'b1 : 1'b0;
        for (m = 0; m < MAX_ENEMY; m = m + 1) begin
            assign  fPlayerBullet_VS_Enemy_Each[k][m]   = IsCollision(
                                                            c_PlayerBulletPosition[k], 
                                                            c_EnemyPosition[m], 
                                                            BULLET_WIDTH, 
                                                            BULLET_HEIGHT, 
                                                            ENEMY_WIDTH, 
                                                            ENEMY_HEIGHT
                                                        ) ? 1'b1 : 1'b0;
        end
        assign  fPlayerBullet_VS_Enemy[k]           = |fPlayerBullet_VS_Enemy_Each[k] ? 1'b1 : 1'b0;
        assign  fPlayerBulletCollision[k]           = fPlayerBullet_VS_EnemyBullet[k] | fPlayerBullet_VS_Enemy[k];
    end

    for (n = 0; n < MAX_ENEMY; n = n + 1) begin
        for (o = 0; o < MAX_PLAYER_BULLET; o = o + 1) begin
            assign  fEnemy_VS_PlayerBullet_Each[n][o]   = IsCollision(
                                                            c_EnemyPosition[n], 
                                                            c_PlayerBulletPosition[o], 
                                                            ENEMY_WIDTH, 
                                                            ENEMY_HEIGHT, 
                                                            BULLET_WIDTH, 
                                                            BULLET_HEIGHT
                                                        ) ? 1'b1 : 1'b0;
        end
        assign  fEnemy_VS_PlayerBullet[n]           = |fEnemy_VS_PlayerBullet_Each[n] ? 1'b1 : 1'b0;
        assign  fEnemyCollision[n]                  = fEnemy_VS_PlayerBullet[n];
    end

    for (p = 0; p < MAX_ENEMY_BULLET; p = p + 1) begin
        assign  fPlayer_VS_EnemyBullet_Each[p]      = IsCollision(
                                                        {c_PlayerPosition, PLAYER_CENTER_Y}, 
                                                        c_EnemyBulletPosition[p], 
                                                        PLAYER_WIDTH, 
                                                        PLAYER_HEIGHT, 
                                                        BULLET_WIDTH, 
                                                        BULLET_HEIGHT
                                                    ) ? 1'b1 : 1'b0;
    end
    assign  fPlayer_VS_EnemyBullet  = |fPlayer_VS_EnemyBullet_Each ? 1'b1 : 1'b0;
    assign  fPlayerCollision        = fPlayer_VS_EnemyBullet;

    // Debug
    // TODO : Delete Debug Data
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    wire [9:0] EnemyPosition_X [MAX_ENEMY-1:0];
    wire [8:0] EnemyPosition_Y [MAX_ENEMY-1:0];

    generate    
        for (t = 0; t < MAX_ENEMY; t = t + 1) begin :EnemyPosition
            assign 
                EnemyPosition_X[t] = c_EnemyPosition[t][18:9],
                EnemyPosition_Y[t] = c_EnemyPosition[t][ 8:0];
        end
    endgenerate    
    
    wire [9:0] EnemyBulletPosition_X [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0];
    wire [8:0] EnemyBulletPosition_Y [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0];

    generate    
        for (t = 0; t < MAX_ENEMY; t = t + 1) begin :EnemyBullet
            assign 
                EnemyBulletPosition_X[t][0] = c_EnemyBulletPosition[t][0][18:9],
                EnemyBulletPosition_X[t][1] = c_EnemyBulletPosition[t][1][18:9],
                EnemyBulletPosition_Y[t][0] = c_EnemyBulletPosition[t][0][ 8:0],
                EnemyBulletPosition_Y[t][1] = c_EnemyBulletPosition[t][1][ 8:0];
        end
    endgenerate    

    wire [8:0] PlayerBulletPosition_Y;
    
    assign PlayerBulletPosition_Y = c_PlayerBulletPosition[0][ 8:0];
    // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    // ##############################################################
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
            c_OnPlayState           = ONPLAY_WAITING;
            c_OnPlayCnt             = 0;

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

                for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletPosition[i][j] = n_EnemyBulletPosition[i][j];
                c_EnemyBulletState[i][j]    = n_EnemyBulletState[i][j];
              end
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
            c_OnPlayState           = n_OnPlayState;
            c_OnPlayCnt             = n_OnPlayCnt;

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
            n_PlayerBulletPosition[i] = c_PlayerBulletPosition[i];
        end

        n_PlayerBulletCnt       = c_PlayerBulletCnt;
        n_PlayerShootCoolDown   = c_PlayerShootCoolDown;
        n_PlayerShootPushed     = c_PlayerShootPushed;

        n_GameState             = c_GameState;
        n_OnPlayState           = c_OnPlayState;
        n_OnPlayCnt             = c_OnPlayCnt;

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

                for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                    for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                        n_EnemyBulletPosition[i][j] = NONE;
                        n_EnemyBulletState[i][j]    = 0;
                    end
                end

                n_PlayerState           = 1'b1;
                n_PlayerPosition[18:9]  = PLAYER_CENTER_X;
                n_PlayerPosition[ 8:0]  = PLAYER_CENTER_Y;
                n_PlayerBulletState     = {MAX_PLAYER_BULLET{1'b0}};

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletPosition[i] = NONE;
                end

                n_OnPlayState           = ONPLAY_WAITING;
                n_OnPlayCnt             = 0;

                n_Phase                 = PHASE_1;
                n_PhaseCnt              = 0;

                n_GameState             = GAME_PLAYING;
            end

            GAME_PLAYING: begin
                n_OnPlayState           =
                    fOnPlayWaiting & fTick  ? ONPLAY_CALCVALUE : 
                    fOnPlayCalcValue        ? ONPLAY_MOVE :
                    fOnPlayMove             ? ONPLAY_COLLISION :
                    fOnPlayCollision        ? ONPLAY_CHECKING :
                    fOnPlayChecking         ? ONPLAY_WAITING : c_OnPlayState;

                // Calculate Value
                n_Phase                 = fTick & fNextPhase ? c_Phase + 1 : c_Phase;
                n_PhaseCnt              = fTick ? (fLstPhaseCnt ? 0 : c_PhaseCnt + 1) : c_PhaseCnt;

                n_EnemyBulletFlag       = fTick & fEnemyShoot ? ~c_EnemyBulletFlag : c_EnemyBulletFlag;

                n_PlayerShootCoolDown   = fTick ? (fPlayerShoot ? 4'd11 : {fPlayerCanShoot ? 0 : c_PlayerShootCoolDown - 1}) : c_PlayerShootCoolDown;
                n_PlayerShootPushed     = fTick ? (fPlayerShoot ? 0 : c_PlayerShootPushed | ~i_Btn[1]) : c_PlayerShootPushed;
                n_PlayerBulletCnt       = fTick ? (fPlayerShoot ? c_PlayerBulletCnt + 1 : c_PlayerBulletCnt) : c_PlayerBulletCnt;

                // Moving
                for (i = 0; i < MAX_ENEMY_ROW; i = i + 1) begin
                    n_EnemyPosition[i   ][18:9] = fTick ? ( (^c_Phase) ? c_EnemyPosition[i   ][18:9] + 1 : n_EnemyPosition[i   ][18:9] - 1) : c_EnemyPosition[i   ][18:9];
                    n_EnemyPosition[i+ 5][18:9] = fTick ? (!(^c_Phase) ? c_EnemyPosition[i+ 5][18:9] + 1 : n_EnemyPosition[i+ 5][18:9] - 1) : c_EnemyPosition[i+ 5][18:9];
                    n_EnemyPosition[i+10][18:9] = fTick ? ( (^c_Phase) ? c_EnemyPosition[i+10][18:9] + 1 : n_EnemyPosition[i+10][18:9] - 1) : c_EnemyPosition[i+10][18:9];
                end

                for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                    n_EnemyBulletPosition[i][0] = fTick ? ((!c_EnemyBulletFlag & fEnemyShoot) ? {c_EnemyPosition[i][18:9] + (ENEMY_WIDTH / 2), c_EnemyPosition[i][8:0] + ENEMY_HEIGHT} : { c_EnemyBulletState[i][0] ? c_EnemyBulletPosition[i][0] + ENEMY_BULLET_SPEED : NONE }) : c_EnemyBulletPosition[i][0];
                    n_EnemyBulletPosition[i][1] = fTick ? (( c_EnemyBulletFlag & fEnemyShoot) ? {c_EnemyPosition[i][18:9] + (ENEMY_WIDTH / 2), c_EnemyPosition[i][8:0] + ENEMY_HEIGHT} : { c_EnemyBulletState[i][1] ? c_EnemyBulletPosition[i][1] + ENEMY_BULLET_SPEED : NONE }) : c_EnemyBulletPosition[i][1];
                end

                n_PlayerPosition[18:9] = 
                    (fTick & fPlayerLeftMove  & ~fPlayerLeftTouch)   ? (PlayerPosition_X - PLAYER_SPEED) :
                    (fTick & fPlayerRightMove & ~fPlayerRightTouch)  ? (PlayerPosition_X + PLAYER_SPEED) : PlayerPosition_X;

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletPosition[i] = fTick ? (fPlayerShoot & (i == c_PlayerBulletCnt) ? {c_PlayerPosition[18:9] + (PLAYER_WIDTH / 2), c_PlayerPosition[8:0] - BULLET_HEIGHT} : { c_PlayerBulletState[i] ? c_PlayerBulletPosition[i] - PLAYER_BULLET_SPEED : NONE }) : c_PlayerBulletPosition[i];
                end
                
                // Collision Check
                for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                    n_EnemyBulletState[i][0] = fTick ? ((!c_EnemyBulletFlag & fEnemyShoot) ? 1 : c_EnemyBulletState[i][0] & ~fEnemyBulletOutOfBound[i][0]) : c_EnemyBulletState[i][0];
                    n_EnemyBulletState[i][1] = fTick ? (( c_EnemyBulletFlag & fEnemyShoot) ? 1 : c_EnemyBulletState[i][1] & ~fEnemyBulletOutOfBound[i][1]) : c_EnemyBulletState[i][1];
                end

                for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                    n_PlayerBulletState[i] =  fTick ? (fPlayerShoot & (i == c_PlayerBulletCnt) ? 1 : { c_PlayerBulletState[i] & ~fPlayerBulletOutOfBound[i] }) : c_PlayerBulletState[i];
                end

                // Monitor

                // Game Over Check

                if (!(&c_EnemyState))       n_GameState = GAME_VICTORY;
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
