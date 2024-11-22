module Game (
    clock, tick, playerMoveLeft, playerMoveRight, playerBulletShoot, gameStartStop, 
    enemyState, enemyBulletState, playerState, playerBulletState, 
    enemyPosition, enemyBulletPosition, playerPosition, playerBulletPosition, 
    gameState, stageState, score
);

    parameter GAME_IDLE     = 3'b000;
    parameter GAME_PLAYING  = 3'b001;
    parameter GAME_VICTORY  = 3'b010;
    parameter GAME_DEFEAT   = 3'b011;
    parameter GAME_ERROR    = 3'b100;

    parameter MAX_ENEMY         = 4'b1111;	// 4'd15
    parameter MAX_ENEMY_BULLET  = 5'b11111;	// 4'd31
    parameter MAX_PLAYER_BULLET = 4'b1111;	// 4'd15

    integer i, j;

    input clock, tick;
    input playerMoveLeft, playerMoveRight, playerBulletShoot, gameStartStop;

    output [MAX_ENEMY-1:0]			enemyState;
    output [MAX_ENEMY_BULLET-1:0]	enemyBulletState;
    output							playerState;
    output [MAX_PLAYER_BULLET-1:0]	playerBulletState;
    output [18:0]					enemyPosition			[MAX_ENEMY-1:0];
    output [18:0]					enemyBulletPosition		[MAX_ENEMY_BULLET-1:0];
    output [9:0]					playerPosition;
    output [18:0]					playerBulletPosition	[MAX_PLAYER_BULLET-1:0];
    output [2:0]					gameState;
    output [8:0]					stageState;
    output [13:0]					score;

    reg c_fPlayerLeft,		n_fPlayerLeft;
    reg c_fPlayerRight,		n_fPlayerRight;
    reg c_fPlayerShoot,		n_fPlayerShoot;
    reg c_fGameStartStop,	n_fGameStartStop;

    reg [MAX_ENEMY-1:0]			c_EnemyState,			n_EnemyState;
    reg [MAX_ENEMY_BULLET-1:0]	c_EnemyBulletState,		n_EnemyBulletState;
    reg							c_PlayerState,			n_PlayerState;
    reg [MAX_PLAYER_BULLET-1:0]	c_PlayerBulletState,	n_PlayerBulletState;
    
    reg [18:0]	c_EnemyPosition			[MAX_ENEMY-1:0],			n_EnemyPosition			[MAX_ENEMY-1:0];
    reg [18:0]	c_EnemyBulletPosition	[MAX_ENEMY_BULLET-1:0],		n_EnemyBulletPosition	[MAX_ENEMY_BULLET-1:0];
    reg [9:0]	c_PlayerPosition,									n_PlayerPosition;
    reg [18:0]	c_PlayerBulletPosition	[MAX_PLAYER_BULLET-1:0],	n_PlayerBulletPosition	[MAX_PLAYER_BULLET-1:0];

    reg [2:0]	c_GameState,	n_GameState;
    reg [8:0]	c_StageState,	n_StageState;
    reg [13:0]	c_Score,		n_Score;

    wire fPlayerLeft;
    wire fPlayerRight;
    wire fPlayerShoot;
    wire fGameStartStop;

    // wire [3:0]  resetSignalArray    = {playerMoveLeft, playerMoveRight, playerBulletShoot, gameStartStop};
    // wire        resetSignal         = |resetSignalArray;

    Enemy U0 (c_EnemyState, c_StageState, n_EnemyPosition);

    assign fPlayerLeft			= !playerMoveLeft		&	c_fPlayerLeft;
    assign fPlayerRight			= !playerMoveRight		&	c_fPlayerRight;
    assign fPlayerShoot			= !playerBulletShoot	&	c_fPlayerShoot;
    assign fGameStartStop		= !gameStartStop		&	c_fGameStartStop;

    assign enemyState			= c_EnemyState;
    assign enemyBulletState		= c_EnemyBulletState;
    assign playerState			= c_PlayerState;
    assign playerBulletState	= c_PlayerBulletState;
    assign enemyPosition		= c_EnemyPosition;
    assign enemyBulletPosition	= c_EnemyBulletPosition;
    assign playerPosition		= c_PlayerPosition;
    assign playerBulletPosition	= c_PlayerBulletPosition;
    assign gameState			= c_GameState;
    assign stageState			= c_StageState;
    assign score				= c_Score;

    always @(posedge tick) begin
        c_fPlayerLeft			= n_fPlayerLeft;
        c_fPlayerRight			= n_fPlayerRight;
        c_fPlayerShoot			= n_fPlayerShoot;
        c_fGameStartStop		= n_fGameStartStop;
        c_EnemyState			= n_EnemyState;
        c_EnemyBulletState		= n_EnemyBulletState;
        c_PlayerState			= n_PlayerState;
        c_PlayerBulletState		= n_PlayerBulletState;
        c_EnemyPosition			= n_EnemyPosition;
        c_EnemyBulletPosition	= n_EnemyBulletPosition;
        c_PlayerPosition		= n_PlayerPosition;
        c_PlayerBulletPosition	= n_PlayerBulletPosition
        c_GameState				= n_GameState;
        c_StageState			= n_StageState;
        c_Score					= n_Score;
    end

    always @* begin
        n_fPlayerLeft		= playerMoveLeft;
        n_fPlayerRight		= playerMoveRight;
        n_fPlayerShoot		= playerBulletShoot;
        n_fGameStartStop	= gameStartStop;
        
        case (c_GameState)
            GAME_IDLE: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적
                n_EnemyState = 15'b111_1111_1111_1111;
                n_EnemyBulletState = 31'b000_0000_0000_0000_0000_0000_0000_0000;
                n_PlayerState = 1'b1;
                n_PlayerBulletState = 15'b000_0000_0000_0000;
                n_StageState = 9'b00_0000000;
                n_Score = 14'b00_0000_0000_0000;

                if (fGameStartStop)			n_GameState = GAME_PLAYING;
                else						n_GameState = GAME_IDLE;
            end
            GAME_PLAYING: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 스테이지
                // 2. 동작을 정의: 

                if		(!(&enemyState))	n_GameState = GAME_VICTORY;
                else if (!playerState)		n_GameState = GAME_DEFEAT;
                else if (fGameStartStop)	n_GameState = GAME_IDLE;
                else						n_GameState = GAME_PLAYING;
            end
            GAME_VICTORY: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 
                // 2. 동작을 정의: 

                if (fGameStartStop)			n_GameState = GAME_IDLE;
                else						n_GameState = GAME_VICTORY;
            end
            GAME_DEFEAT: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 
                // 2. 동작을 정의: 

                if (fGameStartStop)			n_GameState = GAME_IDLE;
                else						n_GameState = GAME_DEFEAT;
            end
            GAME_ERROR: begin
                // TODO
                // 1. 상태를 정의: 적, 적 탄, 플레이어, 플레이어 탄, 게임, 스테이지, 점수
                // 2. 동작을 정의: 적, 적 탄, 플레이어, 플레이어 탄, 충돌
                // DONE
                // 1. 상태를 정의: 
                // 2. 동작을 정의: 
            end
        endcase
    end

endmodule
