module Parameter
    # ( 
        // Enemy Setting
        parameter MAX_ENEMY_ROW         = 5;
        parameter MAX_ENEMY_COL         = 3;
        parameter MAX_ENEMY             = MAX_ENEMY_ROW * MAX_ENEMY_COL;

        parameter ENEMY_CENTER_X        = 10'd302;
        parameter ENEMY_CENTER_Y        = 9'd108;
        parameter ENEMY_WIDTH           = 10'd36;
        parameter ENEMY_HEIGHT          = 9'd24;
        parameter ENEMY_GAP_X           = 10'd72;
        parameter ENEMY_GAP_Y           = 9'd60;

        // Player Setting
        parameter PLAYER_CENTER_X       = 10'd302;
        parameter PLAYER_CENTER_Y       = 9'd372;
        parameter PLAYER_WIDTH          = 10'd24;
        parameter PLAYER_HEIGHT         = 9'd36;

        parameter MAX_PLAYER_COOLDOWN   = 11;

        // Bullet
        parameter BULLET_WIDTH      = 10'd4;
        parameter BULLET_HEIGHT     = 9'd16;
        
        parameter MAX_PLAYER_BULLET     = 4'd15;
        parameter MAX_ENEMY_BULLET_SET  = 2;
        parameter MAX_ENEMY_BULLET      = 4'd31;

        parameter ENEMY_BULLET_SPEED    = 2;
        parameter PLAYER_BULLET_SPEED   = 4;

        // Game Setting
        parameter GAME_IDLE         = 3'b000;
        parameter GAME_PLAYING      = 3'b001;
        parameter GAME_VICTORY      = 3'b010;
        parameter GAME_DEFEAT       = 3'b011;
        parameter GAME_ERROR        = 3'b100;

        parameter PHASE_1           = 2'b00;
        parameter PHASE_2	        = 2'b01;
        parameter PHASE_3	        = 2'b10;
        parameter PHASE_4	        = 2'b11;

        parameter MAX_PHASE_CNT     = 124;

        // Display        
        parameter H_DISPLAY         = 640;
        parameter H_FRONT           = 16;
        parameter H_SYNC            = 96;
        parameter H_BACK            = 48;
        parameter V_DISPLAY         = 480;
        parameter V_FRONT           = 10;
        parameter V_SYNC            = 2;
        parameter V_BACK            = 33;
        parameter H_TOTAL           = H_DISPLAY + H_FRONT + H_SYNC + H_BACK;
        parameter V_TOTAL           = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;

        parameter CENTER_X	        = 302;
        parameter CENTER_Y	        = 108;


        // etc
        parameter NONE              = {10'd720, 9'd500};    //  updated, 소멸된 개체는 여백의 중앙에 위치
        parameter VERTICAL_BORDER   = V_DISPLAY - BULLET_HEIGHT;

	         
        
        
    ) ();

endmodule
