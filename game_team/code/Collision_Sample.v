module Collision_Sample (i_ObjA_Position, i_ObjB_Position, o_fCollision);
    input [9:0] i_ObjA_Position;
    input [9:0] i_ObjB_Position;
    output o_fCollision;


    
    wire [4:0] ObjA_x = i_ObjA_Position[9:5];
    wire [4:0] ObjA_y = i_ObjA_Position[4:0];

    wire [4:0] ObjB_x = i_ObjB_Position[9:5]; 
    wire [4:0] ObjB_y = i_ObjB_Position[4:0];x  

  
endmodule
