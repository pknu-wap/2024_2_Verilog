module GALAGA
    (
        input   i_Clk, i_Rst,
        output  o_Clk,
        output  [ 2:0]  o_pixelState
    );

    parameter 
        MAX_ENEMY           = 15,
        MAX_ENEMY_BULLET    = 30,
        MAX_PLAYER_BULLET   = 16;

    parameter
        DISPLAY_VERTICAL    = 640,
        DISPLAY_HORIZONTAL  = 480;
        
    parameter
        BULLET_WIDTH        = 6,
        BULLET_HEIGHT       = 20;
        
    parameter
        ENEMY_CENTER_X      = 10'd302, 
        ENEMY_CENTER_Y      = 9'd108,
        ENEMY_GAP_X         = 10'd72, 
        ENEMY_GAP_Y         = 9'd60, 
        PLAYER_CENTER_X     = 10'd302, 
        PLAYER_CENTER_Y     = 9'd372;

    parameter
        DEAD_POSITION       = {10'd720, 9'd500},                // dead position updated
        VERTICAL_BORDER     = DISPLAY_VERTICAL - BULLET_HEIGHT;

    parameter 
        H_DISPLAY           = 640,
        H_FRONT             = 16,
        H_SYNC              = 96,
        H_BACK              = 48,
        V_DISPLAY           = 480,
        V_FRONT             = 10,
        V_SYNC              = 2,
        V_BACK              = 33,
        H_TOTAL             = H_DISPLAY + H_FRONT + H_SYNC + H_BACK,
        V_TOTAL             = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;

    localparam ENEMY_WIDTH          = 10'd36;   // 36px
    localparam ENEMY_HEIGHT         = 9'd24;    // 24px
    localparam PLAYER_WIDTH         = 10'd24;   // 24px
    localparam PLAYER_HEIGHT        = 9'd36;    // 36px
    localparam ENEMY_BULLET_WIDTH   = 10'd4;    // 4px
    localparam ENEMY_BULLET_HEIGHT  = 9'd16;    // 16px
    localparam PLAYER_BULLET_WIDTH  = 10'd4;    // 4px
    localparam PLAYER_BULLET_HEIGHT = 9'd16;    // 16px
    
    genvar gen_i, gen_j, gen_k;
    integer i, j;

    reg [ 9:0]  c_PixelPos_x, n_PixelPos_x;
    reg [ 9:0]  c_PixelPos_y, n_PixelPos_y;
    
    reg [18:0]  c_EnemyPosition         [MAX_ENEMY-1:0],            n_EnemyPosition         [MAX_ENEMY-1:0];
    reg [18:0]  c_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0],     n_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];

    reg [18:0]  c_PlayerPosition,                                   n_PlayerPosition;
    reg [18:0]  c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

    reg [32:0] coordTempX[14:0];
    reg [32:0] coordTempY[14:0];

    wire    fPlayer, fPlayerBullet, fEnemy, fEnemyBullet;

    wire    [MAX_PLAYER_BULLET-1:0] fPlayerBullet_Each;
    wire    [MAX_ENEMY-1:0]         fEnemy_Each;
    wire    [MAX_ENEMY_BULLET-1:0]  fEnemyBullet_Each;

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

    generate
        assign  fPlayer = is_in_range(c_PlayerPosition[18:9], {1'b0, c_PlayerPosition[8:0]}, PLAYER_WIDTH, {1'b0, PLAYER_HEIGHT}, c_PixelPos_x, c_PixelPos_y);
        for (gen_i = 0; gen_i < MAX_PLAYER_BULLET; gen_i = gen_i + 1) begin
            assign  fPlayerBullet_Each[gen_i]   = is_in_range(
                                                    c_PlayerBulletPosition[gen_i][18:9], 
                                                    {1'b0, c_PlayerBulletPosition[gen_i][8:0]},
                                                    PLAYER_BULLET_WIDTH, 
                                                    {1'b0, PLAYER_BULLET_HEIGHT}, 
                                                    c_PixelPos_x, 
                                                    c_PixelPos_y
                                                );
        end
        assign  fPlayerBullet   = |fPlayerBullet_Each;
        for (gen_j = 0; gen_j < MAX_ENEMY; gen_j = gen_j + 1) begin
            assign  fEnemy_Each[gen_j]          = is_in_range(
                                                    c_EnemyPosition[gen_j][18:9], 
                                                    {1'b0, c_EnemyPosition[gen_j][8:0]}, 
                                                    ENEMY_WIDTH, 
                                                    {1'b0, ENEMY_HEIGHT}, 
                                                    c_PixelPos_x, 
                                                    c_PixelPos_y
                                                );
        end
        assign  fEnemy          = |fEnemy_Each;
        for (gen_k = 0; gen_k < MAX_ENEMY_BULLET; gen_k = gen_k + 1) begin
            assign  fEnemyBullet_Each[gen_k]    = is_in_range(
                                                    c_EnemyBulletPosition[gen_k][18:9], 
                                                    {1'b0, c_EnemyBulletPosition[gen_k][8:0]}, 
                                                    ENEMY_BULLET_WIDTH, 
                                                    {1'b0, ENEMY_BULLET_HEIGHT}, 
                                                    c_PixelPos_x, 
                                                    c_PixelPos_y
                                                );
        end
        assign  fEnemyBullet    = |fEnemyBullet_Each;
    endgenerate

    assign  o_Clk = i_Clk;
    assign  o_pixelState =  fPlayer         ? 3'b001 :
                            fPlayerBullet   ? 3'b010 :
                            fEnemyBullet    ? 3'b100 :
                            fEnemy          ? 3'b011 : 3'b000;

    always @* begin
        if (c_PixelPos_x < H_TOTAL - 1) begin
            n_PixelPos_x = c_PixelPos_x + 1;
            n_PixelPos_y = c_PixelPos_y;
        end
        else begin
            n_PixelPos_x = 0;
            if (c_PixelPos_y < V_TOTAL - 1) n_PixelPos_y = c_PixelPos_y + 1;
            else                            n_PixelPos_y = 0;
        end

        for (i = 0; i < MAX_ENEMY; i = i + 1) begin
            n_EnemyPosition[i] = c_EnemyPosition[i];
        end
        
        for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
            n_EnemyBulletPosition[i] = c_EnemyBulletPosition[i];
        end

        n_PlayerPosition = c_PlayerPosition;
        
        for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
            n_PlayerBulletPosition[i] = c_PlayerBulletPosition[i];
        end
    end

    always @(posedge i_Clk, negedge i_Rst) begin
        if (~i_Rst) begin
            c_PixelPos_x = 0;
            c_PixelPos_y = 0;

            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    coordTempX[(5 * i) + j] = ENEMY_CENTER_X + ((j - 2) * ENEMY_GAP_X);
                    coordTempY[(5 * i) + j] = ENEMY_CENTER_Y + ((i - 1) * ENEMY_GAP_Y);
                    c_EnemyPosition[(5 * i) + j] = {coordTempX[(5 * i) + j][9:0], coordTempY[(5 * i) + j][8:0]};
                    // $display("i=%d, j=%d, index=%d, coord=%b", i, j, (5 * i) + j, {(ENEMY_CENTER_X + ((j - 2) * ENEMY_GAP_X))[9:0], (ENEMY_CENTER_Y + ((i - 1) * ENEMY_GAP_Y))[8:0]});
                end
            end

            c_EnemyBulletPosition[0] = {10'd315, 9'd120};
            c_EnemyBulletPosition[1] = {10'd100, 9'd200};
            c_EnemyBulletPosition[2] = {10'd200, 9'd300};


            for (i = 3; i < MAX_ENEMY_BULLET; i = i + 1) begin
                c_EnemyBulletPosition[i] = DEAD_POSITION;
            end

            c_PlayerPosition        = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

            c_PlayerBulletPosition[0] = {10'd200, 9'd200};
            c_PlayerBulletPosition[1] = {10'd300, 9'd300};

            for (i = 2; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = DEAD_POSITION;
            end

        end else begin
            c_PixelPos_x = n_PixelPos_x;
            c_PixelPos_y = n_PixelPos_y;
            
            for (i = 0; i < MAX_ENEMY; i = i + 1) begin
                c_EnemyPosition[i] = n_EnemyPosition[i];
            end
            
            for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
                c_EnemyBulletPosition[i] = n_EnemyBulletPosition[i];
            end

            c_PlayerPosition = n_PlayerPosition;
            
            for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
                c_PlayerBulletPosition[i] = n_PlayerBulletPosition[i];
            end
        end
    end

endmodule