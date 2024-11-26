module GALAGA(
  input i_Clk,
  input [9:0] i_n_PixelPos_x, //현재x좌표
  input [9:0] i_n_PixelPos_y, //현재y좌표
  input [14:0] i_enemyState, //모든적상태
  input [284:0] i_enemyPosition, //모든적좌표
  input [30:0] i_enemyBulletState, //적모든포탄상태
  input [18:0] i_enemyBulletPosition [0:30], //적모든포탄좌표
  input i_playerState,  //사용자상태
  input [9:0] i_playerPosition,  //사용자좌표
  input [14:0] i_playerBulletState, //사용자모든포탄상태
  input [18:0] i_playerBulletPosition [0:40], //사용자모든포탄좌표
  output reg [2:0] o_pixelState //현재위치색과상태
);

  // 객체 크기 상수 정의
  localparam ENEMY_WIDTH = 6'b100100;  // 36px
  localparam ENEMY_HEIGHT = 5'b11000;   // 24px
  localparam PLAYER_WIDTH = 5'b11000;   // 24px
  localparam PLAYER_HEIGHT = 6'b100100;  // 36px
  localparam ENEMY_BULLET_WIDTH = 3'b100;     // 4px
  localparam ENEMY_BULLET_HEIGHT = 5'b10000;   // 16px
  localparam PLAYER_BULLET_WIDTH = 3'b100;     // 4px
  localparam PLAYER_BULLET_HEIGHT = 5'b10000;   // 16px

  reg [9:0] r_enemy_x, r_enemy_y; //적위치
  reg [9:0] r_bullet_x, r_bullet_y; //총알위치
  reg [9:0] r_player_x, r_player_y; //플레이어위치

  //범위확인
  function is_in_range(
  input [9:0] i_obj_x, i_obj_y;       //좌표
  input [9:0] i_obj_width, i_obj_height; //크기
  input [9:0] i_n_pixel_x, i_n_pixel_y;);  //현재좌표
  begin
    is_in_range = (i_n_pixel_x >= i_obj_x) && (i_n_pixel_x < i_obj_x + i_obj_width) &&
                  (i_n_pixel_y >= i_obj_y) && (i_n_pixel_y < i_obj_y + i_obj_height);
  end
  endfunction

  always @(posedge i_Clk) begin
    o_pixelState = 3'b000;

    //사용자총알확인
    r_bullet_x = 0;
    r_bullet_y = 0;

    //사용자총알좌표설정
    {r_bullet_x, r_bullet_y} =
      (i_playerBulletState[0] ? i_playerBulletPosition[0] :
      (i_playerBulletState[1] ? i_playerBulletPosition[1] :
      (i_playerBulletState[2] ? i_playerBulletPosition[2] :
      (i_playerBulletState[3] ? i_playerBulletPosition[3] :
      (i_playerBulletState[4] ? i_playerBulletPosition[4] :
      (i_playerBulletState[5] ? i_playerBulletPosition[5] :
      (i_playerBulletState[6] ? i_playerBulletPosition[6] :
      (i_playerBulletState[7] ? i_playerBulletPosition[7] :
      (i_playerBulletState[8] ? i_playerBulletPosition[8] :
      (i_playerBulletState[9] ? i_playerBulletPosition[9] :
      (i_playerBulletState[10] ? i_playerBulletPosition[10] :
      (i_playerBulletState[11] ? i_playerBulletPosition[11] :
      (i_playerBulletState[12] ? i_playerBulletPosition[12] :
      (i_playerBulletState[13] ? i_playerBulletPosition[13] :
      (i_playerBulletState[14] ? i_playerBulletPosition[14] :
      (i_playerBulletState[15] ? i_playerBulletPosition[15] : {0, 0}))))))))))))))));

    // 사용자 총알 범위 확인 후 픽셀 상태 설정
    o_pixelState = 
      (|i_playerBulletState && 
      is_in_range(r_bullet_x, r_bullet_y, PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, i_n_PixelPos_x, i_n_PixelPos_y)) 
      ? 3'b010 
      : o_pixelState;

    // 사용자확인
    o_pixelState = 
      (i_playerState && 
      is_in_range(i_playerPosition, 280, PLAYER_WIDTH, PLAYER_HEIGHT, i_n_PixelPos_x, i_n_PixelPos_y)) 
      ? 3'b001 
      : o_pixelState;

    // 적확인
    r_enemy_x = 0;
    r_enemy_y = 0;

    // 적 활성화 상태 검사 및 좌표 설정
    {r_enemy_x, r_enemy_y} =
      (i_enemyState[0] ? i_enemyPosition[18:0] :
      (i_enemyState[1] ? i_enemyPosition[37:19] :
      (i_enemyState[2] ? i_enemyPosition[56:38] :
      (i_enemyState[3] ? i_enemyPosition[75:57] :
      (i_enemyState[4] ? i_enemyPosition[94:76] :
      (i_enemyState[5] ? i_enemyPosition[113:95] :
      (i_enemyState[6] ? i_enemyPosition[132:114] :
      (i_enemyState[7] ? i_enemyPosition[151:133] :
      (i_enemyState[8] ? i_enemyPosition[170:152] :
      (i_enemyState[9] ? i_enemyPosition[189:171] :
      (i_enemyState[10] ? i_enemyPosition[208:190] :
      (i_enemyState[11] ? i_enemyPosition[227:209] :
      (i_enemyState[12] ? i_enemyPosition[246:228] :
      (i_enemyState[13] ? i_enemyPosition[265:247] :
      (i_enemyState[14] ? i_enemyPosition[284:266] : {0, 0})))))))))))))));

    // 적 범위 확인 후 픽셀 상태 설정
    o_pixelState = 
      (|i_enemyState && 
      is_in_range(r_enemy_x, r_enemy_y, ENEMY_WIDTH, ENEMY_HEIGHT, i_n_PixelPos_x, i_n_PixelPos_y)) 
      ? 3'b100 
      : o_pixelState;

    // 적총알확인
    r_bullet_x = 0;
    r_bullet_y = 0;

    // 적 총알 활성화 상태 검사 및 좌표 설정
    {r_bullet_x, r_bullet_y} =
      (i_enemyBulletState[0] ? i_enemyBulletPosition[0] :
      (i_enemyBulletState[1] ? i_enemyBulletPosition[1] :
      (i_enemyBulletState[2] ? i_enemyBulletPosition[2] :
      (i_enemyBulletState[3] ? i_enemyBulletPosition[3] :
      (i_enemyBulletState[4] ? i_enemyBulletPosition[4] :
      (i_enemyBulletState[5] ? i_enemyBulletPosition[5] :
      (i_enemyBulletState[6] ? i_enemyBulletPosition[6] :
      (i_enemyBulletState[7] ? i_enemyBulletPosition[7] :
      (i_enemyBulletState[8] ? i_enemyBulletPosition[8] :
      (i_enemyBulletState[9] ? i_enemyBulletPosition[9] :
      (i_enemyBulletState[10] ? i_enemyBulletPosition[10] :
      (i_enemyBulletState[11] ? i_enemyBulletPosition[11] :
      (i_enemyBulletState[12] ? i_enemyBulletPosition[12] :
      (i_enemyBulletState[13] ? i_enemyBulletPosition[13] :
      (i_enemyBulletState[14] ? i_enemyBulletPosition[14] :
      (i_enemyBulletState[15] ? i_enemyBulletPosition[15] :
      (i_enemyBulletState[16] ? i_enemyBulletPosition[16] :
      (i_enemyBulletState[17] ? i_enemyBulletPosition[17] :
      (i_enemyBulletState[18] ? i_enemyBulletPosition[18] :
      (i_enemyBulletState[19] ? i_enemyBulletPosition[19] :
      (i_enemyBulletState[20] ? i_enemyBulletPosition[20] :
      (i_enemyBulletState[21] ? i_enemyBulletPosition[21] :
      (i_enemyBulletState[22] ? i_enemyBulletPosition[22] :
      (i_enemyBulletState[23] ? i_enemyBulletPosition[23] :
      (i_enemyBulletState[24] ? i_enemyBulletPosition[24] :
      (i_enemyBulletState[25] ? i_enemyBulletPosition[25] :
      (i_enemyBulletState[26] ? i_enemyBulletPosition[26] :
      (i_enemyBulletState[27] ? i_enemyBulletPosition[27] :
      (i_enemyBulletState[28] ? i_enemyBulletPosition[28] :
      (i_enemyBulletState[29] ? i_enemyBulletPosition[29] :
      (i_enemyBulletState[30] ? i_enemyBulletPosition[30] : {0, 0})))))))))))))))))))))))))))))));

    // 적 총알 범위 확인 후 픽셀 상태 설정
    o_pixelState = 
      (|i_enemyBulletState && 
      is_in_range(r_bullet_x, r_bullet_y, ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, i_n_PixelPos_x, i_n_PixelPos_y)) 
      ? 3'b011 
      : o_pixelState;
end

endmodule

