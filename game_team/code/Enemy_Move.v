module Enemy_Move (   
        input       [9:0]   i_EnemyPosition,
        input       [1:0]   i_PhaseState,
        input               i_fReverse

        output      [9:0]   o_EnemyPosition
    );

    assign o_EnemyPosition = (^i_PhaseState) ^ i_fReverse ? i_EnemyPosition[18:9] - 1, i_EnemyPosition[18:9] + 1;

endmodule
