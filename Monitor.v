module Monitor(
  input i_Clk,
  output reg o_Clk,
  output reg [7:0] o_Red,          
  output reg [7:0] o_Green,
  output reg [7:0] o_Blue,
  output reg o_vSync,
  output reg o_hSync,       
  output reg o_Blank,  
  output reg [9:0] n_PixelPos_X,
  output reg [9:0] n_PixelPos_Y
);

wire [2:0] pixelColor;

parameter H_DISPLAY = 640,
          H_FRONT = 16,
          H_SYNC = 96,
          H_BACK = 48,
          V_DISPLAY = 480,
          V_FRONT = 10,
          V_SYNC = 2,
          V_BACK = 33,
          H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK,
          V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;

initial begin
    n_PixelPos_X = 0;
    n_PixelPos_Y = 0;
    o_Clk =0;
  end

always @(posedge i_Clk) begin
    o_Clk = ~o_Clk;
  end

always @(posedge o_Clk) begin
  if (n_PixelPos_X < H_TOTAL - 1)
    n_PixelPos_X = n_PixelPos_X + 1;
  else begin
    n_PixelPos_X = 0;
    if (n_PixelPos_Y < V_TOTAL - 1)
      n_PixelPos_Y = n_PixelPos_Y + 1;
    else
      n_PixelPos_Y = 0;
  end

  o_hSync = ~((n_PixelPos_X >= H_DISPLAY + H_FRONT) && (n_PixelPos_X < H_DISPLAY + H_FRONT + H_SYNC));
  o_vSync = ~((n_PixelPos_Y >= V_DISPLAY + V_FRONT) && (n_PixelPos_Y < V_DISPLAY + V_FRONT + V_SYNC));
  o_Blank = ((n_PixelPos_X < H_DISPLAY) && (n_PixelPos_Y < V_DISPLAY));
    end


always @(*) begin
     if (o_Blank) begin
        case (pixelColor)
            3'b000: begin
                o_Red = 0;
                o_Green = 0;
                o_Blue = 0;
            end
            3'b010: begin //playerBullet, green
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
    end

endmodule
