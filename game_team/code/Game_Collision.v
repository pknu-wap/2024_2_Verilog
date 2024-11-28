module Game_Collision;

    genvar ii, jj, k, l, m, n, o, p;

    // ##############################################################
    // wire
    // Collision
    wire    [MAX_PLAYER_BULLET-1:0] fEnemyBullet_VS_PlayerBullet_Each   [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0];
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_VS_PlayerBullet        [MAX_ENEMY_BULLET_SET-1:0];
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

    // ##############################################################
    // assign
    // Collision
    for (ii = 0; ii < MAX_ENEMY_BULLET; ii = ii + 1) begin :EBPBCCO
        for (jj = 0; jj < MAX_PLAYER_BULLET; jj = jj + 1) begin :EBPBCCI
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

    // ##############################################################
    // function
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

endmodule