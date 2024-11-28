module FND_GALAGA(i_Clk, i_Rst, 
                  i_GameStartStop, i_Score,
                  o_Sec0, o_Sec1,o_Sec2, o_Score, 
                  i_Num, o_FND);

    input [3:0] i_Num;
    output reg [6:0] o_FND;
 
    input wire        i_Clk;
    input wire        i_Rst;

    input wire        i_GameStartStop;
    input wire [13:0] i_Score;

    output reg [6:0]  o_Sec0, o_Sec1, o_Sec2;
    output reg [13:0] o_Score;

    parameter LST_CLK = 100_000_000 - 1; 
    reg [22:0] c_ClkCnt, n_clkCnt;

    reg [3:0]  c_Sec0, c_Sec1, c_Sec2;

    reg        c_GamePlaying;
    
    always @(posedge i_Clk or negedge i_Rst) begin
        if (!i_Rst) begin
            c_ClkCnt <= 0;
            c_Sec0 <= 0;
            c_Sec1 <= 0;
            c_Sec2 <= 0;
            c_GamePlaying <= 0;
            o_Score <= 0;

        end else begin
            if (i_GameStartStop) begin
                c_GamePlaying <= 1;
            end
            
            if (c_GamePlaying) begin
                if (c_ClkCnt >= LST_CLK) begin
                    c_ClkCnt <= 0;

                    if (c_Sec0 == 9) begin
                        c_Sec0 <= 0;

                        if (c_Sec1 == 9) begin
                            c_Sec1 <= 0;

                            if (c_Sec2 == 9) begin
                                c_Sec2 <= 0;

                            end else begin
                                c_Sec2 <= c_Sec2 + 1;
                            end

                        end else begin
                            c_Sec1 <= c_Sec1 + 1;
                        end

                    end else begin
                        c_Sec0 <= c_Sec0 + 1;
                    end

                    o_Score <= i_Score;

                end else begin
                    c_ClkCnt <= c_ClkCnt + 1;
                end

            end else begin
                c_GamePlaying <= i_GameStartStop;
            end

        end
    end

    always @* begin
        o_Sec0 = c_Sec0;
        o_Sec1 = c_Sec1;
        o_Sec2 = c_Sec2;
    end

    always@*
        case (i_Num)
            4'h0: o_FND = 7'b1000000;
            4'h1: o_FND = 7'b1111001;
            4'h2: o_FND = 7'b0100100;
            4'h3: o_FND = 7'b0110000;
            4'h4: o_FND = 7'b0011001;
            4'h5: o_FND = 7'b0010010;
            4'h6: o_FND = 7'b0000010;
            4'h7: o_FND = 7'b1111000;
            4'h8: o_FND = 7'b0000000;
            4'h9: o_FND = 7'b0010000;
    endcase


endmodule
