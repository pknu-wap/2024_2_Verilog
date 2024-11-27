// 입출력 핀 개수에 제한이 있을 수 있음

// 적 쪼개기
// 적 계산 알고리즘 개선
module Enemy (
    enemyState, stageState, enemyPosition
);

    parameter MAX_ENEMY = 4'b1111;    // 4'd15
    
    parameter PHASE_1   = 2'b00;
    parameter PHASE_2   = 2'b01;
    parameter PHASE_3   = 2'b10;
    parameter PHASE_4   = 2'b11;

    parameter CENTER_X  = 302;
    parameter CENTER_Y  = 108;
    parameter GAP_X     = 72;
    parameter GAP_Y     = 60;

    integer i, j;

    input   [MAX_ENEMY-1:0] enemyState;
    input   [8:0]           stageState;

    output  [18:0]          enemyPosition [MAX_ENEMY-1:0];

    wire    [1:0]           phaseState;
    wire    [6:0]           phaseTick;

    assign {phaseState, phaseTick} = stageState;

    always @* begin
        for (i = 0; i < 3; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                if (phaseState == PHASE_1) begin
                    if (i == 0 || i == 2) begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X - phaseTick, CENTER_Y + (i - 1) * GAP_Y} : 19'b111_1111_1111_1111_1111;
                    end else begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X + phaseTick, CENTER_Y + (i - 1) * GAP_Y} : 18'b111_1111_1111_1111_1111;
                    end
                end
                if (phaseState == PHASE_2) begin
                    if (i == 0 || i == 2) begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X - (142 - phaseTick), CENTER_Y + (i - 1) * GAP_Y} : 19'b111_1111_1111_1111_1111;
                    end else begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X + (142 - phaseTick), CENTER_Y + (i - 1) * GAP_Y} : 19'b111_1111_1111_1111_1111;
                    end
                end
                if (phaseState == PHASE_3) begin
                    if (i == 0 || i == 2) begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X + phaseTick, CENTER_Y + (i - 1) * GAP_Y} : 19'b111_1111_1111_1111_1111;
                    end else begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X - phaseTick, CENTER_Y + (i - 1) * GAP_Y} : 19'b111_1111_1111_1111_1111;
                    end
                end
                if (phaseState == PHASE_4) begin
                    if (i == 0 || i == 2) begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X + (142 - phaseTick), CENTER_Y + (i - 1) * GAP_Y} : 19'b111_1111_1111_1111_1111;
                    end else begin
                        enemyPosition[5 * i + j] <= enemyState ? {CENTER_X + (j - 2) * GAP_X - (142 - phaseTick), CENTER_Y + (i - 1) * GAP_Y} : 19'b111_1111_1111_1111_1111;
                    end
                end
            end
        end
    end

endmodule
