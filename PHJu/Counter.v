module Counter(i_Clk, i_Rst, i_Push, o_LED, o_FND1,o_FND2);
    input i_Clk; // 50MHz
    input i_Rst;
    input [1:0] i_Push;
    output wire [3:0] o_LED;

    output wire [6:0] o_FND1;
    output wire [6:0] o_FND2;

    reg [3:0] c_Cnt1, n_Cnt1;
    reg [3:0] c_Cnt2, n_Cnt2;
    reg [1:0] c_UpDn, n_UpDn;

    wire fUp;
    wire fDn;

    FND FND1(c_Cnt1, o_FND1);
    FND FND2(c_Cnt2,o_FND2);

    always@(posedge i_Clk, posedge i_Rst)
        if(i_Rst) begin
            c_Cnt1 = 0;
            c_Cnt2 = 0;
            c_UpDn = 2'b11;
        end else begin
            c_Cnt1 = n_Cnt1;
            c_Cnt2 = n_Cnt2;
            c_UpDn = n_UpDn;
        end

    assign {fUp, fDn} = ~i_Push & c_UpDn;
    assign o_LED = c_Cnt;

    always@*
        begin
            n_UpDn = i_Push;
            n_Cnt1 = fUp ? c_Cnt * 2 :
                    fDn ? c_Cnt / 2 : c_Cnt + 1;
            if(n_Cnt1>=10){
                n_Cnt2=n_Cnt1/10;
                n_Cnt1-n_Cnt1%10;
            }
        end

endmodule
