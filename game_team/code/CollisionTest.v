// 'include "./Parameter.v"

module Collision
    # ( 
        // Parameter
        parameter MAX_ENEMY         = 4'd3, 
        parameter MAX_ENEMY_BULLET  = 4'd3, 
        parameter MAX_PLAYER_BULLET = 4'd3, 

        parameter GAME_IDLE         = 3'b000, 
        parameter GAME_PLAYING      = 3'b001, 
        parameter GAME_VICTORY      = 3'b010, 
        parameter GAME_DEFEAT       = 3'b011, 
        parameter GAME_ERROR        = 3'b100, 

        parameter ENEMY_CENTER_X    = 10'd302, 
        parameter ENEMY_CENTER_Y    = 9'd108, 
        parameter ENEMY_GAP_X       = 10'd72, 
        parameter ENEMY_GAP_Y       = 9'd60, 
        parameter PLAYER_CENTER_X   = 10'd302, 
        parameter PLAYER_CENTER_Y   = 9'd372,

        parameter ENEMY_WIDTH       = 10'd36, 
        parameter ENEMY_HEIGHT      = 9'd24, 
        parameter PLAYER_WIDTH      = 10'd24, 
        parameter PLAYER_HEIGHT     = 9'd36, 
        parameter BULLET_WIDTH      = 10'd4, 
        parameter BULLET_HEIGHT     = 9'd16, 

        // parameter NONE           = {19{1'b1}},               deprecated
        parameter NONE              = {10'd720, 9'd500},    //  updated, 소멸된 개체는 여백의 중앙에 위치
        parameter MONITOR_WIDTH     = 10'd640, 
        parameter MONITOR_HEIGHT    = 9'd480, 
             
        parameter PHASE_1           = 2'b00, 
        parameter PHASE_2	        = 2'b01, 
        parameter PHASE_3	        = 2'b10, 
        parameter PHASE_4	        = 2'b11, 

        parameter CENTER_X	        = 302, 
        parameter CENTER_Y	        = 108, 
        parameter GAP_X		        = 72, 
        parameter GAP_Y		        = 60
    ) (
        input i_Clk, i_Rst
    );

    genvar i, j, k, l, m, n, o, p;
    integer q, r, s;

    reg     [MAX_ENEMY-1:0]         i_EnemyState;
    reg     [MAX_ENEMY_BULLET-1:0]  i_EnemyBulletState;
    reg                             i_PlayerState;
    reg     [MAX_PLAYER_BULLET-1:0] i_PlayerBulletState;
    reg     [18:0]                 	i_EnemyPosition         [MAX_ENEMY-1:0];
    reg     [18:0]                	i_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];
    reg     [9:0]                   i_PlayerPosition;
    reg     [18:0]                  i_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    reg     [MAX_ENEMY-1:0]         o_EnemyState;
    reg     [MAX_ENEMY_BULLET-1:0]  o_EnemyBulletState;
    reg                             o_PlayerState;
    reg     [MAX_PLAYER_BULLET-1:0] o_PlayerBulletState;
    reg     [18:0]                  o_EnemyPosition         [MAX_ENEMY-1:0];
    reg     [18:0]                  o_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];
    reg     [9:0]                   o_PlayerPosition;
    reg     [18:0]                  o_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_Border;
    wire    [MAX_PLAYER_BULLET-1:0] fEnemyBullet_VS_PlayerBullet_Each   [MAX_ENEMY_BULLET-1:0];
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_PlayerBullet;
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_Player;
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBulletCollision;

    wire    [MAX_PLAYER_BULLET-1:0] fPlayerBullet_VS_Border;
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

            horizontalCollision = ((Ax1 <= Bx1) & (Bx1 <= Ax2)) || ((Ax1 <= Bx2) & (Bx2 <= Ax2));
            verticalCollision   = ((Ay1 <= By1) & (By1 <= Ay2)) || ((Ay1 <= By2) & (By2 <= Ay2));
            
            IsCollision         = horizontalCollision & verticalCollision;
        end
    endfunction

    // Collision
    generate
        // EnemyBulletCollision
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
            assign  fEnemyBullet_VS_Border[i]       = (i_EnemyBulletPosition[i][8:0] > (MONITOR_HEIGHT - BULLET_HEIGHT)) ? 1'b1 : 1'b0;
            for (j = 0; j < MAX_PLAYER_BULLET; j = j + 1) begin
                assign  fEnemyBullet_VS_PlayerBullet_Each[i][j] = IsCollision(
                                                                    i_EnemyBulletPosition[i], 
                                                                    i_PlayerBulletPosition[j], 
                                                                    BULLET_WIDTH, 
                                                                    BULLET_HEIGHT, 
                                                                    BULLET_WIDTH, 
                                                                    BULLET_HEIGHT
                                                                ) ? 1'b1 : 1'b0;
            end
            assign  fEnemyBullet_VS_PlayerBullet[i] = |fEnemyBullet_VS_PlayerBullet_Each[i] ? 1'b1 : 1'b0;
            assign  fEnemyBullet_VS_Player[i]       = IsCollision(
                                                        i_EnemyBulletPosition[i], 
                                                        {i_PlayerPosition, PLAYER_CENTER_Y}, 
                                                        BULLET_WIDTH, 
                                                        BULLET_HEIGHT, 
                                                        PLAYER_WIDTH, 
                                                        PLAYER_HEIGHT
                                                    ) ? 1'b1 : 1'b0;
            assign  fEnemyBulletCollision[i]        = fEnemyBullet_VS_Border[i] | fEnemyBullet_VS_PlayerBullet[i] | fEnemyBullet_VS_Player[i];
        end

        // PlayerBulletCollision
        for (k = 0; k < MAX_PLAYER_BULLET; k = k + 1) begin
            assign  fPlayerBullet_VS_Border[k]      = ~|i_PlayerBulletPosition[k][8:2] ? 1'b1 : 1'b0;
            for (l = 0; l < MAX_ENEMY_BULLET; l = l + 1) begin
                assign  fPlayerBullet_VS_EnemyBullet_Each[k][l] = IsCollision(
                                                                    i_PlayerBulletPosition[k], 
                                                                    i_EnemyBulletPosition[l], 
                                                                    BULLET_WIDTH, 
                                                                    BULLET_HEIGHT, 
                                                                    BULLET_WIDTH, 
                                                                    BULLET_HEIGHT
                                                                ) ? 1'b1 : 1'b0;
            end
            assign  fPlayerBullet_VS_EnemyBullet[k] = |fPlayerBullet_VS_EnemyBullet_Each[k] ? 1'b1 : 1'b0;
            for (m = 0; m < MAX_ENEMY; m = m + 1) begin
                assign  fPlayerBullet_VS_Enemy_Each[k][m]   = IsCollision(
                                                                i_PlayerBulletPosition[k], 
                                                                i_EnemyPosition[m], 
                                                                BULLET_WIDTH, 
                                                                BULLET_HEIGHT, 
                                                                ENEMY_WIDTH, 
                                                                ENEMY_HEIGHT
                                                            ) ? 1'b1 : 1'b0;
            end
            assign  fPlayerBullet_VS_Enemy[k]       = |fPlayerBullet_VS_Enemy_Each[k] ? 1'b1 : 1'b0;
            assign  fPlayerBulletCollision[k]       = fPlayerBullet_VS_Border[k] | fPlayerBullet_VS_EnemyBullet[k] | fPlayerBullet_VS_Enemy[k];
        end

        // EnemyCollision
        for (n = 0; n < MAX_ENEMY; n = n + 1) begin
            for (o = 0; o < MAX_PLAYER_BULLET; o = o + 1) begin
                assign  fEnemy_VS_PlayerBullet_Each[n][o]   = IsCollision(
                                                                i_EnemyPosition[n], 
                                                                i_PlayerBulletPosition[o], 
                                                                ENEMY_WIDTH, 
                                                                ENEMY_HEIGHT, 
                                                                BULLET_WIDTH, 
                                                                BULLET_HEIGHT
                                                            ) ? 1'b1 : 1'b0;
            end
            assign  fEnemy_VS_PlayerBullet[n]       = |fEnemy_VS_PlayerBullet_Each[n] ? 1'b1 : 1'b0;
            assign  fEnemyCollision[n]              = fEnemy_VS_PlayerBullet[n];
        end

        // PlayerCollision
        for (p = 0; p < MAX_ENEMY_BULLET; p = p + 1) begin
            assign  fPlayer_VS_EnemyBullet_Each[p]  = IsCollision(
                                                        {i_PlayerPosition, PLAYER_CENTER_Y}, 
                                                        i_EnemyBulletPosition[p], 
                                                        PLAYER_WIDTH, 
                                                        PLAYER_HEIGHT, 
                                                        BULLET_WIDTH, 
                                                        BULLET_HEIGHT
                                                    ) ? 1'b1 : 1'b0;
        end
        assign  fPlayer_VS_EnemyBullet  = |fPlayer_VS_EnemyBullet_Each ? 1'b1 : 1'b0;
        assign  fPlayerCollision        = fPlayer_VS_EnemyBullet;
    endgenerate

    // Processing

    always @(posedge i_Clk, negedge i_Rst) begin
        if (~i_Rst) begin
            i_EnemyBulletState[0] = 1'b1;
            i_EnemyBulletState[1] = 1'b1;
            i_EnemyBulletState[2] = 1'b1;
            i_EnemyBulletPosition[0] = {10'd150, 9'd200};
            i_EnemyBulletPosition[1] = {10'd200, 9'd360};
            i_EnemyBulletPosition[2] = {10'd300, 9'd250};

            i_PlayerBulletState[0] = 1'b1;
            i_PlayerBulletState[1] = 1'b1;
            i_PlayerBulletState[2] = 1'b1;
            i_PlayerBulletPosition[0] = {10'd250, 9'd150};
            i_PlayerBulletPosition[1] = {10'd302, 9'd260};
            i_PlayerBulletPosition[2] = {10'd320, 9'd120};

            i_EnemyState[0] = 1'b1;
            i_EnemyState[1] = 1'b1;
            i_EnemyState[2] = 1'b1;
            i_EnemyPosition[0] = {10'd100, 9'd100};
            i_EnemyPosition[1] = {10'd200, 9'd100};
            i_EnemyPosition[2] = {10'd300, 9'd100};

            i_PlayerState = 1'b1;
            i_PlayerPosition = {10'd202};
        end else begin
            // EnemyBulletProcessing
            for (q = 0; q < MAX_ENEMY_BULLET; q = q + 1) begin
                o_EnemyBulletState[q]       = fEnemyBulletCollision[q]  ? 1'b0 : i_EnemyBulletState[q];
                o_EnemyBulletPosition[q]    = fEnemyBulletCollision[q]  ? NONE : i_EnemyBulletPosition[q];
            end

            // PlayerBulletProcessing
            for (r = 0; r < MAX_PLAYER_BULLET; r = r + 1) begin
                o_PlayerBulletState[r]      = fPlayerBulletCollision[r] ? 1'b0 : i_PlayerBulletState[r];
                o_PlayerBulletPosition[r]   = fPlayerBulletCollision[r] ? NONE : i_PlayerBulletPosition[r];
            end

            // EnemyProcessing
            for (s = 0; s < MAX_ENEMY; s = s + 1) begin
                o_EnemyState[s]             = fEnemyCollision[s]        ? 1'b0 : i_EnemyState[s];
                o_EnemyPosition[s]          = fEnemyCollision[s]        ? NONE : i_EnemyPosition[s];
            end

            // PlayerProcessing
            o_PlayerState                   = fPlayerCollision          ? 1'b0 : i_PlayerState;
            o_PlayerPosition                = fPlayerCollision          ? NONE : i_PlayerPosition;
        end
    end

endmodule
