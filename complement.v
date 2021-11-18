`timescale 1ns/100ps
//2'S COMPLEMENT 
module comp(OPERAND,COMP_OPERAND);
     
    //INITIALISE PORTS
    input [7:0] OPERAND;
    output reg [7:0] COMP_OPERAND ;
    integer i;

    //ALWAYS WITH A OPERAND
    always@(OPERAND) 
    begin 
        //BIT-WISE TAKE NOT VALUE OF ELEMENT
        for(i=0;i<8;i++)
        begin
            //IF 0 CONVERT TO 1
            if(OPERAND[i]==1'b0)
               COMP_OPERAND[i]=1'b1;
            else
               COMP_OPERAND[i]=1'b0;
        end
        
        //ADD ONE 
        #1 COMP_OPERAND=COMP_OPERAND+8'd1;
    end

endmodule