module Parameter
    #( 
        //Common Parameter
        parameter MAX_ENEMY         = 4'd15, 
        parameter MAX_ENEMY_BULLET  = 4'd31, 
        parameter MAX_PLAYER_BULLET = 4'd15,         

        //Game Parameter
        parameter GAME_IDLE         = 3'b000, 
        parameter GAME_PLAYING      = 3'b001, 
        parameter GAME_VICTORY      = 3'b010, 
        parameter GAME_DEFEAT       = 3'b011, 
        parameter GAME_ERROR        = 3'b100, 

        //parameter MAX_ENEMY         = 4'd15, 
        //parameter MAX_ENEMY_BULLET  = 4'd31, 
        //parameter MAX_PLAYER_BULLET = 4'd15, 

        parameter ENEMY_CENTER_X    = 10'd302, 
        parameter ENEMY_CENTER_Y    = 9'd108, 
        parameter ENEMY_GAP_X       = 10'd72, 
        parameter ENEMY_GAP_Y       = 9'd60, 
        parameter PLAYER_CENTER_X   = 10'd302, 
        parameter PLAYER_CENTER_Y   = 9'd372,

        //Bullet_Gen_And_Move Parameter
        //parameter MAX_ENEMY         = 4'd15, 
        //parameter MAX_ENEMY_BULLET  = 4'd31, 
        //parameter MAX_PLAYER_BULLET = 4'd15,

        //Collision Parameter
        //parameter MAX_ENEMY         = 4'd15, 
        //parameter MAX_ENEMY_BULLET  = 4'd31, 
        //parameter MAX_PLAYER_BULLET = 4'd15, 

        parameter ENEMY_WIDTH       = 10'd36, 
        parameter ENEMY_HEIGHT      = 9'd24, 
        parameter PLAYER_WIDTH      = 10'd24, 
        parameter PLAYER_HEIGHT     = 9'd36, 
        parameter BULLET_WIDTH      = 10'd4, 
        parameter BULLET_HEIGHT     = 9'd16, 

        parameter NONE              = {19{1'b1}},
       
        //Enemy Parameter

        ///parameter MAX_ENEMY	= 4'b1111,	// 4'd15
	         
         parameter PHASE_1	= 2'b00,
         parameter PHASE_2	= 2'b01,
         parameter PHASE_3	= 2'b10,
         parameter PHASE_4	= 2'b11,

         parameter CENTER_X	= 302,
         parameter CENTER_Y	= 108,
         parameter GAP_X		= 72,
         parameter GAP_Y		= 60   

    ) (    );


endmodule