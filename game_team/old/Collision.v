'include "./Parameter.v"

module Collision

    genvar i, j, k, l, m, n, o, p, q, r, s;

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

            horizontalCollision = ~(Ax2 <= Bx1 | Ax1 >= Bx2);
            verticalCollision   = ~(Ay2 <= By1 | Ay1 >= By2);
            
            IsCollision         = horizontalCollision & verticalCollision;
        end
    endfunction

    // Collision
    generate
        // EnemyBulletCollision
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
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
            assign  fEnemyBulletCollision[i]        = fEnemyBullet_VS_PlayerBullet[i] | fEnemyBullet_VS_Player[i];
        end

        // PlayerBulletCollision
        for (k = 0; k < MAX_PLAYER_BULLET; k = k + 1) begin
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
            assign  fPlayerBulletCollision[k]       = fPlayerBullet_VS_EnemyBullet[k] | fPlayerBullet_VS_Enemy[k];
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
    generate
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
    endgenerate

endmodule
