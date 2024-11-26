module Monitor(
    input wire i_clk,
    input wire [9:0] i_n_PixelPos_X,
    input wire [9:0] i_n_PixelPos_Y,
    input wire [14:0] i_enemyState,
    input wire [284:0] i_enemyPosition,
    input wire [30:0] i_enemyBulletState,
    input wire [588:0] i_enemyBulletPosition,
    input wire i_playerState,
    input wire [9:0] i_playerPosition,
    input wire [14:0] i_playerBulletState,
    input wire [284:0] i_playerBulletPosition,
    output reg [7:0] o_Red,
    output reg [7:0] o_Green,
    output reg [7:0] o_Blue
);

    wire [2:0] pixelColor;

    GALAGA_1 G0 (
        i_clk(i_clk),
        i_n_PixelPos_X(i_n_PixelPos_X),
        i_n_PixelPos_Y(i_n_PixelPos_Y),
        i_enemyState(i_enemyState),
        i_enemyPosition(i_enemyPosition),
        i_enemyBulletState(i_enemyBulletState),
        i_enemyBulletPosition(i_enemyBulletPosition),
        i_playerState(i_playerState),
        i_playerPosition(i_playerPosition),
        i_playerBulletState(i_playerBulletState),
        i_playerBulletPosition(i_playerBulletPosition),
        o_pixelState(pixelColor)
    );

    always @* begin
        case (pixelColor)
            3'b000: begin
                o_Red = 0;
                o_Green = 0;
                o_Blue = 0;
            end
            3'b010: begin? //playerBullet, green
                o_Red = 0;
                o_Green = 255;
                o_Blue = 0;
            end
            3'b001: begin //player, blue
                o_Red = 0;
                o_Green = 0;
                o_Blue = 255;
            end
            3'b011: begin //enemyBullet, yellow
                o_Red = 255;
                o_Green = 255;
                o_Blue = 0;
            end
            3'b100: begin //enemy, red
                o_Red = 255;
                o_Green = 0;
                o_Blue = 0;
            end
            default: begin
                o_Red = 0;
                o_Green = 0;
                o_Blue = 0;
            end
        endcase
    end

endmodule
