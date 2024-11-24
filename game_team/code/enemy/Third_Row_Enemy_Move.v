module Third_Row_Enemy_Move
    # ( 
        parameter NONE              = 19'b111_1111_1111_1111_1111, 
        parameter VERTICAL_POSITION = 9'd168
    ) (   
        input               i_EnemyState,
        input       [18:0]  i_EnemyPosition,
        input       [1:0]   i_PhaseState,

        output reg  [18:0]  o_EnemyPosition
    );

    always @* begin
        if (i_EnemyState) begin
            case (i_PhaseState)
                2'b00, 2'b11: o_EnemyPosition = {i_EnemyPosition[18:9] - 1, VERTICAL_POSITION};
                2'b01, 2'b10: o_EnemyPosition = {i_EnemyPosition[18:9] + 1, VERTICAL_POSITION};
            endcase
        end else o_EnemyPosition = NONE;
    end

endmodule
