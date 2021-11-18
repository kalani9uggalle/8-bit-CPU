
`timescale 1ns/100ps
//MODULE PC CONTROL_UNIT
module cu(PC,ADD,CLK,RESET,BUSY,PC_OUT);
    //PC AND ADD VALUE FOE J AND BEQ
    input [31:0] PC,ADD;
    input CLK,RESET,BUSY;//BUSTWAIT ->BUSY
    //INCREMENTED PC 
    output reg [31:0] PC_OUT;
    //INTERMEDIATE ASSIGNMENT
    wire [31:0] PC_INC; //ADDITION OF VALUES OF TWO ADDERS
    wire [31:0] ADDER1; //PC+4 VALUE
    wire [31:0] ADDER2; //BEQ,J,BNE OFFSET PART


    //AT RESET PC CONVERT TO -4   
    always@(RESET)
    begin
        if(RESET)
        begin
          #1             //PC UPDATE DELAY
          PC_OUT=-32'd4; //PC=-4
        end
    end  

    
    assign ADDER2 =ADD;          //ADDITIONAL SHIFT VALUE TO OFFSET -->"ADD"
    assign PC_INC=ADDER1+ADDER2;//PC INCREMENT BY 4 +ADDITIONAL SHIFT 

 
    //SYNCRONIZE WITH POSEDGE CLK
    always@(posedge CLK)
    begin  #1 
        //IF NOT THE RESET
        if(!RESET)begin
        if(!BUSY)//CHECK IF BUSYWAIT BEFORE INCREMENTING PC
        begin
          
          //PC UPDATE WITH #1 DELAY
         
          PC_OUT=PC_INC;
        end  
        end
    end

    adder_4 add4(PC,ADDER1);//PC INCREMENT BY 4 ADDER 
    /***PC+4 ADDER IS CALLED HERE.MODULE IS AT two_adders.v  .ADDER FOR CALCULATING J,BEQ,BNE IS CALLED AT ADDER.V AND RESULTING ADD VALUE IS TAKEN AS INPUT FOR CU AS  "ADD" .**/

endmodule
