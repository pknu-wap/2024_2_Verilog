module GALAGA_1(
  input [9:0] n_PixelPos_x,
  input [9:0] n_PixelPos_y,
  input [14:0] enemyState,
  input [284:0] enemyPosition,
  input [30:0] enemyBulletState,
  input [588:0] enemyBulletPosition,
  input playerState,
  input [9:0] playerPosition,
  input [14:0] playerBulletState,
  input [284:0] playerBulletPosition,
  output reg [2:0] pixelState);

  integer i;
  reg [9:0] enemy_x, enemy_y, bullet_x, bullet_y, player_x, player_y;

  always@(*) begin
    pixelState = 3'b000;

    for (i=0; i<31; i=i+1) begin
      if (enemyBulletState[i]) begin
          bullet_x = enemyBulletPosition[(19*i)+9 : (19*i)];
          bullet_y = enemyBulletPosition[(19*i)+18 : (19*i)+10];
        if ((n_PixelPos_x >= bullet_x) && (n_PixelPos_x < bullet_x + 4) &&
            (n_PixelPos_y >= bullet_y) && (n_PixelPos_y < bullet_y + 16)) begin
            pixelState = 3'b010;
        end
      end
    end

    for (i=0; i<15; i=i+1) begin
      if (enemyState[i]) begin
        enemy_x = enemyPosition[(19*i)+9 : (19*i)];
        enemy_y = enemyPosition[(19*i)+18 : (19*i)+10];
       if ((n_PixelPos_x >= enemy_x) && (n_PixelPos_x < enemy_x + 36) &&
            (n_PixelPos_y >= enemy_y) && (n_PixelPos_y < enemy_y + 24)) begin
            pixelState = 3'b001;
        end
      end
    end

    for (i=0; i<15; i=i+1) begin
      if (playerBulletState[i]) begin
        bullet_x = playerBulletPosition[(19*i)+9 : (19*i)];
        bullet_y = playerBulletPosition[(19*i)+18 : (19*i)+10];
        if ((n_PixelPos_x >= bullet_x) && (n_PixelPos_x < bullet_x + 4) &&
            (n_PixelPos_y >= bullet_y) && (n_PixelPos_y < bullet_y + 16)) begin
            pixelState = 3'b100;
        end
      end
    end
    
      if (playerState) begin
        player_x = playerPosition;
        player_y = 280;
        if ((n_PixelPos_x >= player_x) && (n_PixelPos_x < player_x + 24) &&
            (n_PixelPos_y >= player_y) && (n_PixelPos_y < player_y + 36)) begin
            pixelState = 3'b011;
      end
    end
   end
endmodule
