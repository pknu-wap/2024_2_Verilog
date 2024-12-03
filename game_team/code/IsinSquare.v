module IsinSquare(
        input [18:0] i_Obj_Pos,
        input [5:0] i_Obj_W, i_Obj_H, 
        input [9:0] i_Pixel_X, i_Pixel_Y
        output o_fCollision
    );

    wire [9:0] obj_X;
    wire [8:0] obj_Y;
    wire horizontalRange, verticalRange;
    
    assign
        obj_X = i_Obj_Pos[18:9],
        obj_Y = i_Obj_Pos[8:0];
    
    assign
        horizontalRange = (i_Pixel_X >= obj_X) & (i_Pixel_X < obj_X + i_Obj_W);
        verticalRange   = (i_Pixel_Y >= obj_Y) & (i_Pixel_Y < obj_Y + i_Obj_H);
        o_fCollision    = horizontalRange & verticalRange;
    
endmodule
