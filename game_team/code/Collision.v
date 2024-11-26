// 작업 중
// 모듈화 또는 함수화
// 병렬 처리 => 직렬 처리
// 디폴트 위치를 여백의 중앙으로 설정
// temp를 wire로?

'include "./Parameter.v"    // parameter 외부 참조

module Collision 
    #(
        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15, 

        parameter ENEMY_WIDTH       = 10'd36, 
        parameter ENEMY_HEIGHT      = 9'd24, 
        parameter PLAYER_WIDTH      = 10'd24, 
        parameter PLAYER_HEIGHT     = 9'd36, 
        parameter BULLET_WIDTH      = 10'd4, 
        parameter BULLET_HEIGHT     = 9'd16, 

        parameter NONE              = {19{1'b1}}
    ) (
        input   [MAX_ENEMY-1:0]         i_EnemyState, 
        input   [MAX_ENEMY_BULLET-1:0]  i_EnemyBulletState, 
        input                           i_PlayerState, 
        input   [MAX_PLAYER_BULLET-1:0] i_PlayerBulletState, 
        input   [18:0]                 	i_EnemyPosition         [MAX_ENEMY-1:0], 
        input   [18:0]                	i_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        input   [9:0]                   i_PlayerPosition, 
        input   [18:0]                  i_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0], 

        output  [MAX_ENEMY-1:0]         o_EnemyState, 
        output  [MAX_ENEMY_BULLET-1:0]  o_EnemyBulletState, 
        output                          o_PlayerState, 
        output  [MAX_PLAYER_BULLET-1:0] o_PlayerBulletState, 
        output  [18:0]                  o_EnemyPosition         [MAX_ENEMY-1:0], 
        output  [18:0]                  o_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0], 
        output  [9:0]                   o_PlayerPosition, 
        output  [18:0]                  o_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0]
    );

    genvar gen_i;
    genvar gen_j;
    genvar gen_k_outer, gen_k_inner;
    genvar gen_l_outer, gen_l_inner;
    genvar gen_m;

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

            horizontalCollision = ((Ax1 <= Bx1) && (Bx1 <= Ax2)) || ((Ax1 <= Bx2) && (Bx2 <= Ax2));
            verticalCollision   = ((Ay1 <= By1) && (By1 <= Ay2)) || ((Ay1 <= By2) && (By2 <= Ay2));
            
            IsCollision         = horizontalCollision & verticalCollision;
        end
    endfunction

    wire    [MAX_ENEMY_BULLET-1:0]  EnemyBulletState_BorderCollision;
    wire    [MAX_PLAYER_BULLET-1:0] PlayerBulletState_BorderCollision;
    wire    [18:0]                  EnemyBulletPosition_BorderCollision     [MAX_ENEMY_BULLET-1:0];
    wire    [18:0]                  PlayerBulletPosition_BorderCollision    [MAX_PLAYER_BULLET-1:0];

    wire    [MAX_ENEMY_BULLET-1:0]  EnemyBulletState_BulletCollision;
    wire    [MAX_PLAYER_BULLET-1:0] PlayerBulletState_BulletCollision;
    wire    [18:0]                  EnemyBulletPosition_BulletCollision     [MAX_ENEMY_BULLET-1:0];
    wire    [18:0]                  PlayerBulletPosition_BulletCollision    [MAX_PLAYER_BULLET-1:0];

    wire    [MAX_ENEMY-1:0]         EnemyState_BulletCollision;
    wire    [MAX_PLAYER_BULLET-1:0] PlayerBulletState_EnemyCollision;
    wire    [18:0]                  EnemyPosition_BulletCollision           [MAX_ENEMY-1:0];
    wire    [18:0]                  PlayerBulletPosition_EnemyCollision     [MAX_PLAYER_BULLET-1:0];

    wire                            PlayerState_BulletCollision;
    wire    [MAX_ENEMY_BULLET-1:0]  EnemyBulletState_PlayerCollision;
    wire    [18:0]                  PlayerPosition_BulletCollision;
    wire    [18:0]                  EnemyBulletPosition_PlayerCollision     [MAX_ENEMY_BULLET-1:0];

    generate
        // 적 탄 vs 아래 경계
        for (gen_i = 0; gen_i < MAX_ENEMY_BULLET; gen_i = gen_i + 1) begin
            if (i_EnemyBulletPosition[gen_i][8:0] == ((MONITOR_HEIGHT - 1) - BULLET_HEIGHT)) begin
                assign  EnemyBulletState_BorderCollision[gen_i]     = 1'b0;
                assign  EnemyBulletPosition_BorderCollision[gen_i]  = NONE;
            end else begin
                assign  EnemyBulletState_BorderCollision[gen_i]     = i_EnemyBulletState[gen_i];
                assign  EnemyBulletPosition_BorderCollision[gen_i]  = i_EnemyBulletPosition[gen_i];
            end
        end

        // 플레이어 탄 vs 위 경계
        for (gen_j = 0; gen_j < MAX_PLAYER_BULLET; gen_j = gen_j + 1) begin
            if (i_PlayerBulletPosition[gen_i][8:0] == {9{1'b0}}) begin
                assign  PlayerBulletState_BorderCollision[gen_j]    = 1'b0;
                assign  PlayerBulletPosition_BorderCollision[gen_j] = NONE;
            end else begin
                assign  PlayerBulletState_BorderCollision[gen_j]    = i_PlayerBulletState[gen_j];
                assign  PlayerBulletPosition_BorderCollision[gen_j] = i_PlayerBulletPosition[gen_j];
            end
        end

        // 적 탄 vs 플레이어 탄
        for (gen_k_outer = 0; gen_k_outer < MAX_ENEMY_BULLET; gen_k_outer = gen_k_outer + 1) begin
            for (gen_k_inner = 0; gen_k_inner < MAX_PLAYER_BULLET; gen_k_inner = gen_k_inner + 1) begin
                if (IsCollision(
                    EnemyBulletPosition_BorderCollision[gen_k_outer], 
                    PlayerBulletPosition_BorderCollision[gen_k_inner], 
                    BULLET_WIDTH, 
                    BULLET_HEIGHT, 
                    BULLET_WIDTH, 
                    BULLET_HEIGHT
                )) begin
                    assign  EnemyBulletState_BulletCollision[gen_k_outer]       = 1'b0;
                    assign  PlayerBulletState_BulletCollision[gen_k_inner]      = 1'b0;
                    assign  EnemyBulletPosition_BulletCollision[gen_k_outer]    = NONE;
                    assign  PlayerBulletPosition_BulletCollision[gen_k_inner]   = NONE;
                end else begin
                    assign  EnemyBulletState_BulletCollision[gen_k_outer]       = EnemyBulletState_BorderCollision[gen_k_outer];
                    assign  PlayerBulletState_BulletCollision[gen_k_inner]      = PlayerBulletState_BorderCollision[gen_k_inner];
                    assign  EnemyBulletPosition_BulletCollision[gen_k_outer]    = EnemyBulletPosition_BorderCollision[gen_k_outer];
                    assign  PlayerBulletPosition_BulletCollision[gen_k_inner]   = PlayerBulletPosition_BorderCollision[gen_k_inner];
                end
            end
        end

        // 적 vs 플레이어 탄
        for (gen_l_outer = 0; gen_l_outer < MAX_ENEMY; gen_l_outer = gen_l_outer + 1) begin
            for (gen_l_inner = 0; gen_l_inner < MAX_PLAYER_BULLET; gen_l_inner = gen_l_inner + 1) begin
                if (IsCollision(
                    i_EnemyPosition[gen_l_outer], 
                    PlayerBulletPosition_BulletCollision[gen_l_inner], 
                    ENEMY_WIDTH, 
                    ENEMY_HEIGHT, 
                    BULLET_WIDTH, 
                    BULLET_HEIGHT
                )) begin
                    assign  EnemyState_BulletCollision[gen_l_outer]             = 1'b0;
                    assign  PlayerBulletState_EnemyCollision[gen_l_inner]       = 1'b0;
                    assign  EnemyPosition_BulletCollision[gen_l_outer]          = NONE;
                    assign  PlayerBulletPosition_EnemyCollision[gen_l_inner]    = NONE;
                end else begin
                    assign  EnemyState_BulletCollision[gen_l_outer]             = i_EnemyState[gen_l_outer];
                    assign  PlayerBulletState_EnemyCollision[gen_l_inner]       = PlayerBulletState_BulletCollision[gen_l_inner];
                    assign  EnemyPosition_BulletCollision[gen_l_outer]          = i_EnemyPosition[gen_l_inner];
                    assign  PlayerBulletPosition_EnemyCollision[gen_l_inner]    = PlayerBulletPosition_BulletCollision[gen_l_inner];
                end
            end
        end

        // 적 탄 vs 플레이어
        for (gen_m = 0; gen_m < MAX_ENEMY_BULLET; gen_m = gen_m + 1) begin
            if (IsCollision(
                EnemyBulletPosition_BulletCollision[gen_m], 
                i_PlayerPosition, 
                BULLET_WIDTH, 
                BULLET_HEIGHT, 
                PLAYER_WIDTH, 
                PLAYER_HEIGHT
            )) begin
                assign  EnemyBulletState_PlayerCollision[gen_m]     = 1'b0;
                assign  PlayerState_BulletCollision                 = 1'b0;
                assign  EnemyBulletPosition_PlayerCollision[gen_m]  = NONE;
                assign  PlayerPosition_BulletCollision              = NONE:
            end else begin
                assign  EnemyBulletState_PlayerCollision[gen_m]     = EnemyBulletState_BulletCollision[gen_m];
                assign  PlayerState_BulletCollision                 = i_PlayerState;
                assign  EnemyBulletPosition_PlayerCollision[gen_m]  = EnemyBulletPosition_BulletCollision[gen_m];
                assign  PlayerPosition_BulletCollision              = i_PlayerPosition;
            end
        end
    endgenerate

    assign  o_EnemyState            = EnemyState_BulletCollision;
    assign  o_EnemyBulletState      = EnemyBulletState_PlayerCollision;
    assign  o_PlayerState           = PlayerState_BulletCollision;
    assign  o_PlayerBulletState     = PlayerBulletState_EnemyCollision;
    assign  o_EnemyPosition         = EnemyPosition_BulletCollision;
    assign  o_EnemyBulletPosition   = EnemyBulletPosition_PlayerCollision;
    assign  o_PlayerPosition        = PlayerPosition_BulletCollision;
    assign  o_PlayerBulletPosition  = PlayerBulletPosition_EnemyCollision;
    
endmodule
