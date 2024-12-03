module CollisionCheck(
    input [18:0] i_ObjAPos,
    input [18:0] i_ObjBPos,
    input [5:0] i_ObjAWidth,
    input [5:0] i_ObjAHeight,
    input [5:0] i_ObjBWidth,
    input [5:0] i_ObjBHeight,
    output o_AIsCollision,
    output o_BIsCollision
    );

    `include "Parameter.vh" 

    wire         horizontalCollision;
    wire         verticalCollision;
    wire [9:0]   Ax1, Ax2, Bx1, Bx2;
    wire [8:0]   Ay1, Ay2, By1, By2;

    assign  
        {Ax1, Ay1}          = i_ObjAPos,
        {Bx1, By1}          = i_ObjBPos,
        {Ax2, Ay2}          = {Ax1 + i_ObjAWidth    , Ay1 + i_ObjAHeight},
        {Bx2, By2}          = {Bx1 + i_ObjBWidth    , By1 + i_ObjBHeight};

    assign   
        horizontalCollision = ~((Ax2 <= Bx1) | (Ax1 >= Bx2)),
        verticalCollision   = ~((Ay2 <= By1) | (Ay1 >= By2)),    
        o_AIsCollision       = horizontalCollision & verticalCollision,
        o_BIsCollision       = o_AIsCollision;
endmodule
