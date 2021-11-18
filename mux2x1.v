`timescale 1ns/100ps

//mux2X1 MODULE
module mux2x1(SELECT,OPERAND1,OPERAND2,MUXOUT);

    //INITIALISE
    input [7:0]OPERAND1,OPERAND2;
    input SELECT;
    output reg [7:0] MUXOUT;
    
    //AT INPUT CHANGES
    always@(*)
    begin
        //IF 0 SELECT OPERAND1
  	    if(SELECT==1'b0)
  	        MUXOUT=OPERAND1;

        //IF 1 SELECT OPERAND2  
  	    else
  	        MUXOUT=OPERAND2;
  	end

endmodule