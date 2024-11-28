module Bullet_Move(
    input [8:0] i_BulletPosition,
    input       i_fReverse,

    output [8:0] o_BulletPosition
);

    assign o_BulletPosition = i_fReverse ? i_BulletPosition + 1'b1 : i_BulletPosition - 1'b1;

endmodule