module Bullet_Gen_And_Move (input i_Clk, i_Rst, i_Btn);
    parameter 
        MAX_ENEMY_ROW         = 5,
        MAX_ENEMY_COL         = 3,
        MAX_ENEMY             = MAX_ENEMY_ROW * MAX_ENEMY_COL,
        MAX_ENEMY_BULLET_SET  = 2,
        MAX_PLAYER_BULLET     = 16; 

    parameter
        DISPLAY_VERTICAL   = 480,
        DISPLAY_HORIZONTAL = 640;
        
    parameter
        BULLET_WIDTH    = 6,
        BULLET_HEIGHT   = 20;
        
    parameter
        ENEMY_CENTER_X    = 302, 
        ENEMY_CENTER_Y    = 108,
        ENEMY_GAP_X       = 72, 
        ENEMY_GAP_Y       = 60, 
        PLAYER_CENTER_X   = 302, 
        PLAYER_CENTER_Y   = 372;
        
    parameter
        ENEMY_BULLET_SPEED    = 2,
        PLAYER_BULLET_SPEED   = 4;

    parameter
        NONE            = 19'b111_1111_1111_1111_1111,
        VERTICAL_BORDER = DISPLAY_VERTICAL - BULLET_HEIGHT;

    integer i, j;
    genvar x, y, t, p;

    // reg
    reg [MAX_ENEMY-1:0]             c_EnemyState,                      n_EnemyState;
    reg [MAX_ENEMY_BULLET_SET-1:0]  c_EnemyBulletState[MAX_ENEMY-1:0], n_EnemyBulletState[MAX_ENEMY-1:0];
    reg                             c_EnemyBulletFlag,                 n_EnemyBulletFlag;
    
    reg [18:0]          c_EnemyPosition         [MAX_ENEMY-1:0],                            n_EnemyPosition         [MAX_ENEMY-1:0];
    reg [18:0]          c_EnemyBulletPosition   [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0],  n_EnemyBulletPosition   [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0];

    reg                         c_PlayerState,          n_PlayerState;
    reg [MAX_PLAYER_BULLET-1:0] c_PlayerBulletState,    n_PlayerBulletState;

    reg [3:0]           c_PlayerBulletCnt,      n_PlayerBulletCnt;      // ??? ?? ? ???? (0 ~ 15)
    reg [3:0]           c_PlayerShootCoolDown,  n_PlayerShootCoolDown;  // ?? ? Tick ????  (0 ~ 11)
    reg                 c_PlayerShootPushed,    n_PlayerShootPushed;

    reg [18:0]          c_PlayerPosition,       n_PlayerPosition;
    reg [18:0]          c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];


    reg [1:0]           c_Phase,        n_Phase;
    reg [6:0]           c_PhaseCnt,     n_PhaseCnt;

    // wire
    wire fEnemyShoot;
    wire [MAX_ENEMY_BULLET_SET-1:0] fEnemyBulletOutOfBound [MAX_ENEMY-1:0];
    wire [MAX_PLAYER_BULLET-1:0]    fPlayerBulletOutOfBound;

    wire fPlayerCanShoot, fPlayerShoot;

    wire fNextPhase;

    // assign
    assign fNextPhase   = &c_PhaseCnt;
    assign fEnemyShoot  = fNextPhase;

    assign fPlayerCanShoot = ~(|c_PlayerShootCoolDown);
    assign fPlayerShoot = fPlayerCanShoot & c_PlayerShootPushed;

    
    for (x = 0; x < MAX_ENEMY; x = x + 1) begin
      for (y = 0; y < MAX_ENEMY_BULLET_SET; y = y + 1) begin
        assign fEnemyBulletOutOfBound[x][y] = c_EnemyBulletPosition[x][y][8:0] == VERTICAL_BORDER;
      end
    end

    for (p = 0; p < MAX_PLAYER_BULLET; p = p + 1) begin
        assign fPlayerBulletOutOfBound[p] = ~(|c_PlayerBulletPosition[p][8:0]);
    end

    // ########################################################
    // Temporary
    wire [9:0] EnemyPosition_X [MAX_ENEMY-1:0];
    wire [8:0] EnemyPosition_Y [MAX_ENEMY-1:0];
    
    for (t = 0; t < MAX_ENEMY; t = t + 1) begin
      assign EnemyPosition_X[t] = c_EnemyPosition[t][18:9];
      assign EnemyPosition_Y[t] = c_EnemyPosition[t][ 8:0];
    end
    
    wire [9:0] PlayerPosition_X;
    wire [8:0] PlayerPosition_Y;
    
    assign PlayerPosition_X = c_PlayerPosition[18:9];
    assign PlayerPosition_Y = c_PlayerPosition[ 8:0];
    
    wire [8:0] PlayerBulletPosition_Y;
    
    assign PlayerBulletPosition_Y = c_PlayerBulletPosition[0][ 8:0];

    // ########################################################


    always @(posedge i_Clk, negedge i_Rst) begin
        if (~i_Rst) begin
            c_EnemyState            = 15'b111_1111_1111_1111;
            c_EnemyBulletFlag       = 1'b0;

            for (i = 0; i < MAX_ENEMY_COL; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_ROW; j = j + 1) begin
                c_EnemyPosition[MAX_ENEMY_ROW * i + j][18:9] = ENEMY_CENTER_X + (j - (MAX_ENEMY_ROW - 1) / 2) * ENEMY_GAP_X;
                c_EnemyPosition[MAX_ENEMY_ROW * i + j][ 8:0] = ENEMY_CENTER_Y + (i - (MAX_ENEMY_COL - 1) / 2) * ENEMY_GAP_Y;
              end
            end
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletState[i][j] = 0;
              end
            end

            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletPosition[i][j] = NONE;
              end
            end

            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = NONE;
            end

            c_PlayerState           = 1'b1;
            c_PlayerBulletState     = 15'b000_0000_0000_0000;
            c_PlayerBulletCnt       = 4'b0000;
            c_PlayerShootCoolDown   = 0;
            c_PlayerShootPushed     = 0;

            c_PlayerPosition[18:9]  = PLAYER_CENTER_X;
            c_PlayerPosition[ 8:0]  = PLAYER_CENTER_Y;

            c_Phase                 = 2'b00;
            c_PhaseCnt              = 7'b000_0000;

        end else begin
            c_EnemyState            = n_EnemyState;
            c_EnemyBulletFlag       = n_EnemyBulletFlag;
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              c_EnemyPosition[i] = n_EnemyPosition[i];
            end
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyBulletState[i] = n_EnemyBulletState[i];
            end
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletPosition[i][j] = n_EnemyBulletPosition[i][j];
              end
            end

            c_PlayerState           = n_PlayerState;
            c_PlayerBulletState     = n_PlayerBulletState;

            c_PlayerBulletCnt       = n_PlayerBulletCnt;
            c_PlayerShootCoolDown   = n_PlayerShootCoolDown;
            c_PlayerShootPushed     = n_PlayerShootPushed;
            
            c_PlayerPosition        = n_PlayerPosition;

            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = n_PlayerBulletPosition[i];
            end

            c_Phase                 = n_Phase;
            c_PhaseCnt              = n_PhaseCnt;
        end
    end

    always @* begin
        n_Phase                 = fNextPhase ? c_Phase + 1 : c_Phase;
        n_PhaseCnt              = c_PhaseCnt + 1;
        n_EnemyState            = c_EnemyState;
        n_EnemyBulletFlag       = fEnemyShoot ? !c_EnemyBulletFlag : c_EnemyBulletFlag;

        n_PlayerState           = c_PlayerState;
        n_PlayerPosition        = c_PlayerPosition;

        n_PlayerShootCoolDown   = fPlayerShoot ? 4'd11 : {fPlayerCanShoot ? 0 : c_PlayerShootCoolDown - 1};
        n_PlayerShootPushed     = fPlayerShoot ? 0 : c_PlayerShootPushed | ~i_Btn;
        n_PlayerBulletCnt       = fPlayerShoot ? c_PlayerBulletCnt + 1 : c_PlayerBulletCnt;
        
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
          n_EnemyPosition[i] = c_EnemyPosition[i];
        end

        // Enemy Bullet State
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
          for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin  
            n_EnemyBulletState[i][j] = (j == c_EnemyBulletFlag & fEnemyShoot) ?
              1 : c_EnemyBulletState[i][j] & ~fEnemyBulletOutOfBound[i][j];
          end
        end

        // Enemy Bullet Position
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
          for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin 
            n_EnemyBulletPosition[i][j] = (j == c_EnemyBulletFlag & fEnemyShoot) ? 
              c_EnemyPosition[i] : { c_EnemyBulletState[i][j] ? c_EnemyBulletPosition[i][j] + ENEMY_BULLET_SPEED : NONE };
          end
        end

        // Player Bullet State
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            n_PlayerBulletState[i] = fPlayerShoot & (i == c_PlayerBulletCnt) ? 1 : { c_PlayerBulletState[i] & ~fPlayerBulletOutOfBound[i] };
        end

        // Player Bullet Position
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            n_PlayerBulletPosition[i] = fPlayerShoot & (i == c_PlayerBulletCnt) ? 
              c_PlayerPosition : { c_PlayerBulletState[i] ? c_PlayerBulletPosition[i] - PLAYER_BULLET_SPEED : NONE };
        end
    end

endmodule

