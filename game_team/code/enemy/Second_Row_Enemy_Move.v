module Second_Row_Enemy_Move 
    # ( parameter NONE = 10'b11_1111_1111 ) 
    (   
        input               i_EnemyState,
        input       [9:0]   i_EnemyHorizontalPosition,
        input       [1:0]   i_PhaseState,

        output reg  [9:0]   o_EnemyHorizontalPosition
    );

    always @* begin
        if (i_EnemyState) begin
            case (i_PhaseState)
                2'b00, 2'b11: o_EnemyHorizontalPosition = i_EnemyHorizontalPosition + 1;
                2'b01, 2'b10: o_EnemyHorizontalPosition = i_EnemyHorizontalPosition - 1;
            endcase
        end else o_EnemyHorizontalPosition = NONE;
    end

endmodule
