module Counter_N(i_Clk, i_Rst, i_Push, o_LED, o_FND);
    input i_Clk; // 50MHz
    input i_Rst;

    input [2:0] i_Push;
    // i_Push[0] = i_Up
    // i_Push[1] = i_Down
    // i_Push[2] = i_Five     

    output wire [3:0] o_LED;
    output wire [6:0] o_FND;

    reg [3:0] c_Cnt, n_Cnt;

    reg [2:0] c_IsPressed, n_IsPressed; 
    
    // reg c_Up, n_Up;         
    // reg c_Down, n_Down;     
    // reg c_Five, n_Five;   
  
    wire [2:0] fPressed;   

    // wire fUp;           
    // wire fDown;         
    // wire fFive;         

    FND FND0(c_Cnt, o_FND);


    always@(posedge i_Clk, posedge i_Rst)
        if(i_Rst) begin
            c_Cnt = 0;
            c_IsPressed = 1'b1;
            //c_Up = 1'b1;
            //c_Down = 1'b1;
            //c_Five = 1'b1;

        end else begin
            c_Cnt = n_Cnt;
            c_IsPressed = n_IsPressed; 
            //c_Up = n_Up;
            //c_Down = n_Down;
            //c_Five = n_Five;
        end

    assign fPressed = ~i_Push & c_IsPressed;
    //assign fUp = ~i_Up & c_Up;
    //assign fDown = ~i_Down & c_Down;
    //assign fFive = ~i_Five & c_Five;
    
    assign o_LED = c_Cnt;

    always@* 
        begin 
            n_IsPressed
 = i_Push;

            n_Cnt = fPressed[0] ? (c_Cnt == 9 ? 0 : c_Cnt + 1) : 
                    fPressed[1] ? (c_Cnt == 0 ? 9 : c_Cnt - 1) : 
                    fPressed[2] ? 5 :
                    c_Cnt;
        end

endmodule
