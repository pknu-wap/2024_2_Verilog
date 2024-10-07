module Counter(i_Clk, i_Rst, i_UpDnMode, i_Push, o_LED, o_FND, o_Carry);

    input i_Clk, i_Rst;
    input i_UpDnMode, i_Push;
    output [3:0] o_LED;
    output [6:0] o_FND;
    output o_Carry;

    reg [3:0] c_Cnt, n_Cnt;
    reg c_UpDn, n_UpDn;
    reg Carry;

    wire fUpDn;

    FND FND0(c_Cnt, o_FND);

    assign fUpDn = ~i_Push & c_UpDn;
    assign o_Carry = ~Carry;
    assign o_LED = c_Cnt;

    always @(posedge i_Clk, posedge i_Rst)
        if (i_Rst) begin
            c_Cnt = 4'b0000;
            c_UpDn = 1'b1;
            Carry = 1'b0;
        end else begin
            c_Cnt = n_Cnt;
            c_UpDn = n_UpDn;
        end

    always @* begin
        n_UpDn = i_Push;
        if (fUpDn)
            if (~i_UpDnMode)
                if (c_Cnt == 4'b1001) begin
                    n_Cnt = 4'b0000;
                    Carry = 1'b1;
                end else n_Cnt = c_Cnt + 1;
            else
                if (c_Cnt == 4'b0000) begin
                    n_Cnt = 4'b1001;
                    Carry = 1'b1;
                end else n_Cnt = c_Cnt - 1;
        else begin
           n_Cnt = c_Cnt;
           Carry = 1'b0;
        end
    end

endmodule
