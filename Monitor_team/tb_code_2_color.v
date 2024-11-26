`timescale 1ns / 1ps

module tb_GARAGA;
    reg i_Clk;
    wire [7:0] o_Red, o_Green, o_Blue;
    wire o_vSync, o_hSync;
    wire o_Blank;
    wire [9:0] n_PixelPos_X, n_PixelPos_Y;

GALAGA U0(i_Clk, i_n_PixelPos_x,
  i_n_PixelPos_y,
  i_enemyState,
  i_enemyPosition,
  i_enemyBulletState,
  i_enemyBulletPosition,
  i_playerState,
  i_playerPosition,
  i_playerBulletState,
  i_playerBulletPosition,
  o_pixelState);

always #20 i_Clk = ~i_Clk;

initial begin
    i_Clk = 0;
    #1_000_000;
    $stop;
  end
endmodule

