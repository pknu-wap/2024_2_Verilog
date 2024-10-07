module Counter(i_Clk, i_Rst, i_Push, o_LED, o_FND, o_Carry);

    input i_Clk, i_Rst;
    input [1:0] i_Push;
    output [3:0] o_LED;
    output [6:0] o_FND;
    output [1:0] o_Carry;

    reg [3:0] c_Cnt, n_Cnt;
    reg [1:0] c_UpDn, n_UpDn;
    reg [1:0] Carry;

    wire fUp, fDn;
    
    FND FND0(c_Cnt, o_FND);

    assign {fUp, fDn} = ~i_Push & c_UpDn;
    assign o_Carry = ~Carry;
    assign o_LED = c_Cnt;

    always @(posedge i_Clk, posedge i_Rst)
        if (i_Rst) begin
            c_Cnt = 4'b0000;
            c_UpDn = 2'b11;
            Carry = 2'b00;
        end else begin
            c_Cnt = n_Cnt;
            c_UpDn = n_UpDn;
        end

    always @* begin
        n_UpDn = i_Push;
        if (fUp) 
            if (c_Cnt == 4'b1001) begin
                n_Cnt = 4'b0000;
                Carry[1] = 1'b1;
            end else n_Cnt = c_Cnt + 1;
        else if (fDn) 
            if (c_Cnt == 4'b0000) begin
                n_Cnt = 4'b1001;
                Carry[0] = 1'b1;
            end else n_Cnt = c_Cnt - 1;
        else begin
           n_Cnt = c_Cnt;
           Carry = 2'b00;
        end
    end

endmodule
