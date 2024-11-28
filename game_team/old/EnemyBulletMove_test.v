module Bullet_Gen_And_Move (input i_Clk, i_Rst);

    parameter 
        MAX_ENEMY             = 4,
        MAX_ENEMY_BULLET_SET  = 2,
        MAX_PLAYER_BULLET     = 16; // 연산 편의 위해 16으로 변경

    parameter
        DISPLAY_VERTICAL   = 640,
        DISPLAY_HORIZONTAL = 480;
        
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
        BULLET_SPEED    = 5;

    parameter
        DEAD_POSITION   = 19'b111_1111_1111_1111_1111,
        VERTICAL_BORDER = DISPLAY_VERTICAL - BULLET_HEIGHT;

    integer i, j;
    genvar x, y;

    // reg
    reg [MAX_ENEMY-1:0] c_EnemyState,                                 n_EnemyState;
    reg [MAX_ENEMY-1:0] c_EnemyBulletState[MAX_ENEMY_BULLET_SET-1:0], n_EnemyBulletState[MAX_ENEMY_BULLET_SET-1:0];
    reg                 c_EnemyBulletFlag,                            n_EnemyBulletFlag;
    
    reg [18:0]          c_EnemyPosition         [MAX_ENEMY-1:0],                            n_EnemyPosition         [MAX_ENEMY-1:0];
    reg [18:0]          c_EnemyBulletPosition   [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0],  n_EnemyBulletPosition   [MAX_ENEMY-1:0][MAX_ENEMY_BULLET_SET-1:0];

    reg [1:0]           c_Phase,        n_Phase;
    reg [6:0]           c_PhaseCnt,     n_PhaseCnt;

    // wire
    wire fNextPhase;
    wire fEnemyShoot;
    wire [MAX_ENEMY-1:0] fEnemyBulletLst[MAX_ENEMY_BULLET_SET-1:0];

    // assign
    assign fNextPhase   = &c_PhaseCnt;
    assign fEnemyShoot  = fNextPhase;
    
    for (x = 0; x < MAX_ENEMY; x = x + 1) begin
      for (y = 0; y < MAX_ENEMY_BULLET_SET; y = y + 1) begin
        assign fEnemyBulletLst[y][x] = c_EnemyBulletPosition[y][x][8:0] == VERTICAL_BORDER;
      end
    end


    always @(posedge i_Clk, negedge i_Rst) begin
        if (~i_Rst) begin
            c_EnemyState            = 15'b111_1111_1111_1111;
            c_EnemyBulletFlag       = 1'b0;

            for (i = 0; i < 2; i = i + 1) begin
              for (j = 0; j < 2; j = j + 1) begin
                c_EnemyPosition[2 * i + j] = {ENEMY_CENTER_X + (j - 1) * ENEMY_GAP_X, ENEMY_CENTER_Y + (i - 1) * ENEMY_GAP_Y};
              end
            end
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletState[i][j] = 0;
              end
            end

            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletPosition[i][j] = DEAD_POSITION;
              end
            end

            c_Phase                 = 2'b00;
            c_PhaseCnt              = 7'b000_0000;

        end else begin
            c_EnemyState            = n_EnemyState;
            c_EnemyBulletFlag       = n_EnemyBulletFlag;
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              c_EnemyPosition[i] = n_EnemyPosition[i];
            end
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletState[i][j] = n_EnemyBulletState[i][j];
              end
            end
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
              for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin
                c_EnemyBulletPosition[i][j] = n_EnemyBulletPosition[i][j];
              end
            end
            
            c_Phase                 = n_Phase;
            c_PhaseCnt              = n_PhaseCnt;
        end
    end

    always @* begin
        n_Phase                 = fNextPhase ? c_Phase + 1 : c_Phase;
        n_PhaseCnt              = c_PhaseCnt + 1;
        n_EnemyState            = c_EnemyState;
        n_EnemyBulletFlag       = fNextPhase ? !c_EnemyBulletFlag : c_EnemyBulletFlag;
        
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
          n_EnemyPosition[i] = c_EnemyPosition[i];
        end

        // Enemy Bullet State
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
          for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin  
            n_EnemyBulletState[i][j] = (j == c_EnemyBulletFlag & fEnemyShoot) ?
              1 : c_EnemyBulletState[i][j] & ~fEnemyBulletLst[i][j];
          end
        end

        // Enemy Bullet Position
        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
          for (j = 0; j < MAX_ENEMY_BULLET_SET; j = j + 1) begin 
            n_EnemyBulletPosition[i][j] = (j == c_EnemyBulletFlag & fEnemyShoot) ? 
              c_EnemyPosition[i] : {c_EnemyBulletState[i][j] ? c_EnemyBulletPosition[i][j] + BULLET_SPEED : DEAD_POSITION};
          end
        end
    end

endmodule


