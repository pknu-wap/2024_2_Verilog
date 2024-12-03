module Game_Score;

	// ##############################################################
    // wire
    // FND
	wire	[3:0]	c_Score0, c_Score1, c_Score2;
    wire fLstClk0, fIncClk0;

    assign fLstClk0 = c_Score0 == 9;

	// ##############################################################
    // assign
    // FND
    assign	
		c_Score0	= c_Score - (c_Score2 * 100 + c_Score1 * 10), 
		c_Score1	= (c_Score / 10) - c_Score2 * 10, 
		c_Score2	= c_Score / 100;
    
	// ##############################################################
    // module
    // FND
    FND FND0(c_Score0, o_FND0);
    FND FND1(c_Score1, o_FND1);
    FND FND2(c_Score2, o_FND2);

endmodule