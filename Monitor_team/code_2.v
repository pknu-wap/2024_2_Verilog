module GALAGA_1(
  input i_clk,
  input [9:0] i_n_PixelPos_x, //현재x좌표
  input [9:0] i_n_PixelPos_y, //현재y좌표
  input [14:0] i_enemyState, //모든적상태
  input [284:0] i_enemyPosition, //모든적좌표
  input [30:0] i_enemyBulletState, //적모든포탄상태
  input [588:0] i_enemyBulletPosition, //적모든포탄좌표
  input i_playerState,  //사용자상태
  input [9:0] i_playerPosition,  //사용자좌표
  input [14:0] i_playerBulletState, //사용자모든포탄상태
  input [284:0] i_playerBulletPosition, //사용자모든포탄좌표
  output reg [2:0] o_pixelState //현재위치색과상태
);

  localparam ENEMY_WIDTH = 6'b100100;  // 36px
  localparam ENEMY_HEIGHT = 5'b11000;   // 24px
  localparam PLAYER_WIDTH = 5'b11000;   // 24px
  localparam PLAYER_HEIGHT = 6'b100100;  // 36px
  localparam ENEMY_BULLET_WIDTH = 3'b100;     // 4px
  localparam ENEMY_BULLET_HEIGHT = 5'b10000;   // 16px
  localparam PLAYER_BULLET_WIDTH = 3'b100;     // 4px
  localparam PLAYER_BULLET_HEIGHT = 5'b10000;   // 16px

  integer i;

  always @(posedge i_clk) begin
    o_pixelState = 3'b000; //맨처음기본상태

//사용지총알확인
    for (i = 0; i < 15; i = i + 1) begin
      if (i_playerBulletState[i]) begin
        if ((i_n_PixelPos_X >= i_enemyPosition[i*19 + 9: i*19]) &&  // ENEMY_WIDTH
            (i_n_PixelPos_X < i_enemyPosition[i*19 + 9: i*19] + 36) &&
            (i_n_PixelPos_Y >= i_enemyPosition[i*19 + 18: i*19 + 10]) &&  // ENEMY_HEIGHT
            (i_n_PixelPos_Y < i_enemyPosition[i*19 + 18: i*19 + 10] + 24)) begin
          o_pixelState = 3'b010; // 초록색
        end
      end
    end

//사용자확인
    if (i_playerState) begin
      if ((i_n_PixelPos_X >= i_playerPosition) &&
          (i_n_PixelPos_X < i_playerPosition + 24) &&  // PLAYER_WIDTH
          (i_n_PixelPos_Y >= 480 - 36) &&            // PLAYER_HEIGHT
          (i_n_PixelPos_Y < 480)) begin
        o_pixelState = 3'b001; // 파란색
      end
    end

//적총알확인
    for (i = 0; i < 31; i = i + 1) begin
      if (i_enemyBulletState[i]) begin
        if ((i_n_PixelPos_X >= i_enemyBulletPosition[i*19 + 9: i*19]) &&  // ENEMY_BULLET_WIDTH
            (i_n_PixelPos_X < i_enemyBulletPosition[i*19 + 9: i*19] + 4) &&
            (i_n_PixelPos_Y >= i_enemyBulletPosition[i*19 + 18: i*19 + 10]) &&  // ENEMY_BULLET_HEIGHT
            (i_n_PixelPos_Y < i_enemyBulletPosition[i*19 + 18: i*19 + 10] + 16)) begin
          o_pixelState = 3'b011; // 노란색
        end
      end
    end

//적확인
    for (i = 0; i < 15; i = i + 1) begin
      if (i_enemyState[i]) begin
        if ((i_n_PixelPos_X >= i_enemyPosition[i*19 + 9: i*19]) &&  // ENEMY_WIDTH
                    (i_n_PixelPos_X < i_enemyPosition[i*19 + 9: i*19] + 36) &&
                    (i_n_PixelPos_Y >= i_enemyPosition[i*19 + 18: i*19 + 10]) &&  // ENEMY_HEIGHT
                    (i_n_PixelPos_Y < i_enemyPosition[i*19 + 18: i*19 + 10] + 24)) begin
          o_pixelState = 3'b100; // 빨간색
        end
      end
    end
  end
endmodule
