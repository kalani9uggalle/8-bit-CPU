`timescale 1ns/100ps

//REG-FILE
module reg_file (IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET,BUSY);
   
    
    //INPUT OUTPUT
    input  [7:0] IN;
   	input  [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
   	input  WRITE,RESET,CLK,BUSY;
   	output reg [7:0] OUT1, OUT2;

    //8 x 8 REGISTER
   	reg    [7:0] REGISTER [7:0];
     

    //SYNCHRONIZE WITH RESET
    always@( RESET)
    begin
   
        //IF RESET==1 LEVEL TRIGGERED
	    if(RESET )begin
		    
		    //DELAY 1s FOR RESET
		    #1;

		    //MAKE 8*8 REGISTER ZERO
		    REGISTER[0]<=8'b00000000;
		    REGISTER[1]<=8'b00000000;
		    REGISTER[2]<=8'b00000000;
		    REGISTER[3]<=8'b00000000;
		    REGISTER[4]<=8'b00000000;
		    REGISTER[5]<=8'b00000000;
		    REGISTER[6]<=8'b00000000;
		    REGISTER[7]<=8'b00000000;
	    
	    end

    end 



    //SYNCHRONIZE WITH POSITIVE EDGE OF CLOCK
    always@(posedge CLK)
    begin
        
        //IF WRITE ENABLE
        #1;//DELAY 1s FOR WRITE
        if(WRITE==1 && RESET==0 && BUSY==0)begin

            
	        
	        //ASSIGN INPUT TO THE INADRESS OF REGISTER
	        REGISTER[INADDRESS]<=IN;
        end
     
    end   

 
    
             //EVERYTIME READ FROM REGISTER
   
    always@(*)   begin 
            //DELAY 2s FOR READ
    	    #2 
    	    //READ REGISTER OUTADRESS AND ASSIGN IT TO OUT 
    	    OUT1=REGISTER[OUT1ADDRESS];
    	    OUT2=REGISTER[OUT2ADDRESS];
        
    end
	

endmodule
