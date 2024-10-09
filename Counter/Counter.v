module Counter(i_Clk, i_Rst, i_Push, o_LED, o_FNDA, o_FNDB);//?? ??? ??? ??? ??
    input i_Clk; // 50MHz
    input i_Rst;
    input [1:0] i_Push;
    output wire [3:0] o_LED;
    output wire [6:0] o_FNDA;
    output wire [6:0] o_FNDB;

    reg [3:0] c_Cnt, n_Cnt;
    reg [1:0] c_UpDn, n_UpDn;

    wire fUp;
    wire fDn;

    FND FND0(c_Cnt, o_FNDA, o_FNDB);

    always@(posedge i_Clk, posedge i_Rst)
        if(i_Rst) begin
            c_Cnt = 0;
            c_UpDn = 2'b11;
        end else begin
            c_Cnt = n_Cnt;
            c_UpDn = n_UpDn;
        end

    assign {fUp, fDn} = ~i_Push & c_UpDn;
    assign o_LED = c_Cnt;

    always@*
        begin
            n_UpDn = i_Push;
            n_Cnt = fUp ? c_Cnt + 1 : 
                    fDn ? c_Cnt - 1 : c_Cnt;
        end

endmodule
