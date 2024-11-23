module GALAGA(
  input clk,
  input [9:0] n_PixelPos_x, //현재x좌표
  input [9:0] n_PixelPos_y, //현재y좌표
  input [14:0] enemyState, //모든적상태
  input [284:0] enemyPosition, //모든적좌표
  input [30:0] enemyBulletState, //적모든포탄상태
  input [588:0] enemyBulletPosition, //적모든포탄좌표
  input playerState,  //사용자상태
  input [9:0] playerPosition,  //사용자좌표
  input [14:0] playerBulletState, //사용자모든포탄상태
  input [284:0] playerBulletPosition, //사용자모든포탄좌표
  output reg [2:0] pixelState //현재위치색과상태
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
  reg [9:0] enemy_x, enemy_y; // 적 위치
  reg [9:0] bullet_x, bullet_y; // 총알 위치
  reg [9:0] player_x, player_y; // 플레이어 위치

  always @(posedge clk) begin
    pixelState = 3'b000; //맨처음기본상태

//사용지총알확인
    for (i = 0; i < 15; i = i + 1) begin
      if (playerBulletState[i]) begin
        bullet_x = playerBulletPosition[(19*i)+9 : (19*i)];
        bullet_y = playerBulletPosition[(19*i)+18 : (19*i)+10];
        if ((n_PixelPos_x >= bullet_x) && (n_PixelPos_x < bullet_x + PLAYER_BULLET_WIDTH) &&
            (n_PixelPos_y >= bullet_y) && (n_PixelPos_y < bullet_y + PLAYER_BULLET_HEIGHT)) begin
          pixelState = 3'b010; // 초록색
        end
      end
    end

//사용자확인
    if (playerState) begin
      player_x = playerPosition;
      player_y = 280; // 플레이어의 y 좌표는 고정
      if ((n_PixelPos_x >= player_x) && (n_PixelPos_x < player_x + PLAYER_WIDTH) &&
          (n_PixelPos_y >= player_y) && (n_PixelPos_y < player_y + PLAYER_HEIGHT)) begin
        pixelState = 3'b001; // 파란색
      end
    end

//적총알확인
    for (i = 0; i < 31; i = i + 1) begin
      if (enemyBulletState[i]) begin
        bullet_x = enemyBulletPosition[(19*i)+9 : (19*i)];
        bullet_y = enemyBulletPosition[(19*i)+18 : (19*i)+10];
        if ((n_PixelPos_x >= bullet_x) && (n_PixelPos_x < bullet_x + ENEMY_BULLET_WIDTH) &&
            (n_PixelPos_y >= bullet_y) && (n_PixelPos_y < bullet_y + ENEMY_BULLET_HEIGHT)) begin
          pixelState = 3'b011; // 노란색
        end
      end
    end

//적확인
    for (i = 0; i < 15; i = i + 1) begin
      if (enemyState[i]) begin
        enemy_x = enemyPosition[(19*i)+9 : (19*i)];
        enemy_y = enemyPosition[(19*i)+18 : (19*i)+10];
        if ((n_PixelPos_x >= enemy_x) && (n_PixelPos_x < enemy_x + ENEMY_WIDTH) &&
            (n_PixelPos_y >= enemy_y) && (n_PixelPos_y < enemy_y + ENEMY_HEIGHT)) begin
          pixelState = 3'b100; // 빨간색
        end
      end
    end
  end
endmodule
