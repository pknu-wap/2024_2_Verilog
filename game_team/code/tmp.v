module GALAGA(
  input i_Clk, i_Rst,
  output reg o_Clk,
  output reg [2:0] o_pixelState
);

  parameter 
      MAX_ENEMY         = 15,
      MAX_ENEMY_BULLET  = 30,
      MAX_PLAYER_BULLET = 16;

  parameter
      DISPLAY_VERTICAL   = 640,
      DISPLAY_HORIZONTAL = 480;
      
  parameter
      BULLET_WIDTH    = 6,
      BULLET_HEIGHT   = 20;
      
  parameter
      ENEMY_CENTER_X    = 10'd302, 
      ENEMY_CENTER_Y    = 9'd108,
      ENEMY_GAP_X       = 10'd72, 
      ENEMY_GAP_Y       = 9'd60, 
      PLAYER_CENTER_X   = 10'd302, 
      PLAYER_CENTER_Y   = 9'd372;

  parameter
      DEAD_POSITION   = 19'b111_1111_1111_1111_1111,
      VERTICAL_BORDER = DISPLAY_VERTICAL - BULLET_HEIGHT;

  parameter 
     H_DISPLAY = 640,
     H_FRONT = 16,
     H_SYNC = 96,
     H_BACK = 48,
     V_DISPLAY = 480,
     V_FRONT = 10,
     V_SYNC = 2,
     V_BACK = 33,
     H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK,
     V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;

  localparam ENEMY_WIDTH = 6'b100100;  // 36px
  localparam ENEMY_HEIGHT = 5'b11000;   // 24px
  localparam PLAYER_WIDTH = 5'b11000;   // 24px
  localparam PLAYER_HEIGHT = 6'b100100;  // 36px
  localparam ENEMY_BULLET_WIDTH = 3'b100;     // 4px
  localparam ENEMY_BULLET_HEIGHT = 5'b10000;   // 16px
  localparam PLAYER_BULLET_WIDTH = 3'b100;     // 4px
  localparam PLAYER_BULLET_HEIGHT = 5'b10000;   // 16px

  wire [18:0] enemyPositions[MAX_ENEMY-1:0];
  wire [18:0] enemyBulletPositions[MAX_ENEMY_BULLET-1:0];
  wire [18:0] playerBulletPositions[MAX_PLAYER_BULLET-1:0];

  reg [9:0]                   c_PixelPos_x=10'b000_0000_000,           n_PixelPos_x;
  reg [9:0]                   c_PixelPos_y=10'b000_0000_000,           n_PixelPos_y;

  reg [MAX_ENEMY-1:0]         c_EnemyState,           n_EnemyState;
  reg [MAX_ENEMY_BULLET-1:0]  c_EnemyBulletState,     n_EnemyBulletState;
  
  reg [18:0]                  c_EnemyPosition         [MAX_ENEMY-1:0],            n_EnemyPosition         [MAX_ENEMY-1:0];
  reg [18:0]                  c_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0],     n_EnemyBulletPosition   [MAX_ENEMY_BULLET-1:0];

  reg                         c_PlayerState,          n_PlayerState;
  reg [MAX_PLAYER_BULLET-1:0] c_PlayerBulletState,    n_PlayerBulletState;

  reg [9:0]                  c_PlayerPosition,       n_PlayerPosition;
  reg [18:0]                  c_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0],    n_PlayerBulletPosition  [MAX_PLAYER_BULLET-1:0];

  wire fPlayer, fPlayerBullet, fEnemy, fEnemyBullet;

  function is_in_range(
    input [9:0] i_obj_x, i_obj_y,  
    input [9:0] i_obj_width, i_obj_height, 
    input [9:0] i_n_pixel_x, i_n_pixel_y); 
    begin
      is_in_range = (i_n_pixel_x >= i_obj_x) && (i_n_pixel_x < i_obj_x + i_obj_width) &&
                    (i_n_pixel_y >= i_obj_y) && (i_n_pixel_y < i_obj_y + i_obj_height);
    end
  endfunction

  assign fPlayer = is_in_range(c_PlayerPosition[9:0],c_PlayerPosition[8:0], PLAYER_WIDTH, PLAYER_HEIGHT, c_PixelPos_x, c_PixelPos_y);
  assign fPlayerBullet = 
     (is_in_range(c_PlayerBulletPosition[ 0][18:9], c_PlayerBulletPosition[ 0][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 1][18:9], c_PlayerBulletPosition[ 1][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 2][18:9], c_PlayerBulletPosition[ 2][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 3][18:9], c_PlayerBulletPosition[ 3][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 4][18:9], c_PlayerBulletPosition[ 4][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 5][18:9], c_PlayerBulletPosition[ 5][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 6][18:9], c_PlayerBulletPosition[ 6][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 7][18:9], c_PlayerBulletPosition[ 7][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 8][18:9], c_PlayerBulletPosition[ 8][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[ 9][18:9], c_PlayerBulletPosition[ 9][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[10][18:9], c_PlayerBulletPosition[10][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[11][18:9], c_PlayerBulletPosition[11][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[12][18:9], c_PlayerBulletPosition[12][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[13][18:9], c_PlayerBulletPosition[13][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_PlayerBulletPosition[14][18:9], c_PlayerBulletPosition[14][8:0], PLAYER_BULLET_WIDTH, PLAYER_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y));
  assign fEnemy = 
     (is_in_range(c_EnemyPosition[ 0][18:9], c_EnemyPosition[ 0][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 1][18:9], c_EnemyPosition[ 1][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 2][18:9], c_EnemyPosition[ 2][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 3][18:9], c_EnemyPosition[ 3][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 4][18:9], c_EnemyPosition[ 4][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 5][18:9], c_EnemyPosition[ 5][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 6][18:9], c_EnemyPosition[ 6][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 7][18:9], c_EnemyPosition[ 7][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 8][18:9], c_EnemyPosition[ 8][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[ 9][18:9], c_EnemyPosition[ 9][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[10][18:9], c_EnemyPosition[10][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[11][18:9], c_EnemyPosition[11][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[12][18:9], c_EnemyPosition[12][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[13][18:9], c_EnemyPosition[13][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyPosition[14][18:9], c_EnemyPosition[14][8:0], ENEMY_WIDTH, ENEMY_HEIGHT, c_PixelPos_x, c_PixelPos_y));
  assign fEnemyBullet = 
     (is_in_range(c_EnemyBulletPosition[ 0][18:9], c_EnemyBulletPosition[ 0][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 1][18:9], c_EnemyBulletPosition[ 1][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 2][18:9], c_EnemyBulletPosition[ 2][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 3][18:9], c_EnemyBulletPosition[ 3][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 4][18:9], c_EnemyBulletPosition[ 4][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 5][18:9], c_EnemyBulletPosition[ 5][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 6][18:9], c_EnemyBulletPosition[ 6][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 7][18:9], c_EnemyBulletPosition[ 7][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 8][18:9], c_EnemyBulletPosition[ 8][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[ 9][18:9], c_EnemyBulletPosition[ 9][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[10][18:9], c_EnemyBulletPosition[10][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[11][18:9], c_EnemyBulletPosition[11][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[12][18:9], c_EnemyBulletPosition[12][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[13][18:9], c_EnemyBulletPosition[13][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[14][18:9], c_EnemyBulletPosition[14][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[15][18:9], c_EnemyBulletPosition[15][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[16][18:9], c_EnemyBulletPosition[16][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[17][18:9], c_EnemyBulletPosition[17][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[18][18:9], c_EnemyBulletPosition[18][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[19][18:9], c_EnemyBulletPosition[19][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[20][18:9], c_EnemyBulletPosition[20][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[21][18:9], c_EnemyBulletPosition[21][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[22][18:9], c_EnemyBulletPosition[22][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[23][18:9], c_EnemyBulletPosition[23][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[24][18:9], c_EnemyBulletPosition[24][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[25][18:9], c_EnemyBulletPosition[25][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[26][18:9], c_EnemyBulletPosition[26][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[27][18:9], c_EnemyBulletPosition[27][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[28][18:9], c_EnemyBulletPosition[28][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[29][18:9], c_EnemyBulletPosition[29][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y)) |
     (is_in_range(c_EnemyBulletPosition[30][18:9], c_EnemyBulletPosition[30][8:0], ENEMY_BULLET_WIDTH, ENEMY_BULLET_HEIGHT, c_PixelPos_x, c_PixelPos_y));
  integer i, j;

 


  always @(posedge i_Clk) begin
  if (c_PixelPos_x < H_TOTAL - 1)
    n_PixelPos_x = c_PixelPos_x + 1;
  else begin
    n_PixelPos_x = 0;
    if (c_PixelPos_y < V_TOTAL - 1)
      n_PixelPos_y = c_PixelPos_y + 1;
    else
      n_PixelPos_y = 0;
  end

  //player 
  if (c_PlayerPosition[9:0] < PLAYER_WIDTH - 1)
    n_PlayerPosition[9:0] = c_PlayerPosition[9:0] + 1;
  else begin
    n_PlayerPosition[9:0] = 0;
    if (c_PlayerPosition[8:0] < PLAYER_HEIGHT - 1)
      n_PlayerPosition[8:0] = c_PlayerPosition[8:0] + 1;
    else
      n_PlayerPosition[8:0] = 0;
  end

  //playerbullet
  if (c_PlayerBulletPosition[ 0][18:9] < PLAYER_BULLET_WIDTH - 1)
    n_PlayerBulletPosition[ 0][18:9] = c_PlayerBulletPosition[ 0][18:9] + 1;
  else begin
    n_PlayerBulletPosition[ 0][18:9] = 0;
    if (c_PlayerBulletPosition[ 0][8:0] <  PLAYER_BULLET_HEIGHT - 1)
       n_PlayerBulletPosition[ 0][8:0] =  c_PlayerBulletPosition[ 0][8:0] + 1;
    else
      n_PlayerBulletPosition[ 0][8:0] = 0;
  end

  //enemy
  if (c_EnemyPosition[ 0][18:9] < ENEMY_WIDTH - 1)
    n_EnemyPosition[ 0][18:9] = c_EnemyPosition[ 0][18:9] + 1;
  else begin
    n_EnemyPosition[ 0][18:9] = 0;
    if (c_EnemyPosition[ 0][8:0] < ENEMY_HEIGHT - 1)
        n_EnemyPosition[ 0][8:0] = c_EnemyPosition[ 0][8:0] + 1;
    else
      n_EnemyPosition[ 0][8:0] = 0;
  end

  //enemybullet
  if (c_EnemyBulletPosition[ 0][18:9] < ENEMY_BULLET_WIDTH - 1)
    n_EnemyBulletPosition[ 0][18:9] = c_EnemyBulletPosition[ 0][18:9] + 1;
  else begin
    n_EnemyBulletPosition[ 0][18:9] = 0;
    if (c_EnemyBulletPosition[ 0][8:0] < ENEMY_BULLET_HEIGHT - 1)
      n_EnemyBulletPosition[ 0][8:0] = c_EnemyBulletPosition[ 0][8:0] + 1;
    else
      n_EnemyBulletPosition[ 0][8:0] = 0;
  end
  
end

  always @* begin
  if (fPlayer) o_pixelState = 3'b001;
  else if (fEnemy) o_pixelState = 3'b011;
  else if (fPlayerBullet) o_pixelState = 3'b010;
  else if (fEnemyBullet) o_pixelState = 3'b100;
  else o_pixelState = 3'b000;
end

  always @(posedge i_Clk, negedge i_Rst) begin
    if (~i_Rst) begin
      c_PixelPos_x = 0;
      c_PixelPos_y = 0;
      
      c_EnemyState            = 15'b111_1111_1111_1111;
      //c_EnemyBulletState      = 31'b000_0000_0000_0000_0000_0000_0000_0000;

      for (i = 0; i < 3; i = i + 1) begin
          for (j = 0; j < 5; j = j + 1) begin
              c_EnemyPosition[5 * i + j] = {ENEMY_CENTER_X + (j - 2) * ENEMY_GAP_X, ENEMY_CENTER_Y + (i - 1) * ENEMY_GAP_Y};
          end
      end

      for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
          c_EnemyBulletPosition[i] = DEAD_POSITION;
      end

      for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
        c_PlayerBulletPosition[i] = DEAD_POSITION;
      end

      c_PlayerState           = 1'b1;
      c_PlayerPosition        = {PLAYER_CENTER_X, PLAYER_CENTER_Y};

      for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
          c_PlayerBulletPosition[i] = DEAD_POSITION;
      end

    end else begin
      c_PixelPos_x = n_PixelPos_x;
      c_PixelPos_y = n_PixelPos_y;

      c_EnemyState            = n_EnemyState;
      c_EnemyBulletState      = n_EnemyBulletState;

      c_PlayerState           = n_PlayerState;
      c_PlayerBulletState     = n_PlayerBulletState;
      
      for (i = 0; i < MAX_ENEMY; i = i + 1) begin
        c_EnemyPosition[i] = n_EnemyPosition[i];
      end
      
      for (i = 0; i < MAX_ENEMY_BULLET; i = i + 1) begin
        c_EnemyBulletPosition[i] = n_EnemyBulletPosition[i];
      end

      c_PlayerPosition        = n_PlayerPosition;
      
      for (i = 0; i < MAX_PLAYER_BULLET; i = i + 1) begin
        c_PlayerBulletPosition[i] = n_PlayerBulletPosition[i];
      end
    end
  end

endmodule