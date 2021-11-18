`timescale 1ns/100ps

`include"mux_sl.v"
module alu(DATA1, DATA2, SELECT, RESULT,ZERO);

	//DECLARING PORTS
         input [7:0] DATA1;
         input [7:0] DATA2;
         input [2:0] SELECT;
         output reg [7:0] RESULT;
         output reg  ZERO;
         wire [7:0] OUT1;
         reg [7:0] OUT2;

         wire [7:0] ADD_I,OR_I,AND_I,FD_I;

         assign #2 ADD_I=DATA1 +DATA2;   //DELAY 2s AND DO ADD OPERATION
         assign #1 FD_I =DATA2;          //DELAY 1s AND DO FORWARD OPERATION
         assign #1 AND_I= DATA1 & DATA2; //DELAY 1s AND DO AND OPERATION
         assign #1 OR_I = DATA1 | DATA2; //DELAY 1s AND DO OR  OPERATION
         

       /** //SLL FUNCTION//
        function [7:0] sll(input [7:0] DATA1,input [7:0] DATA2)  ;
        begin
           
            sll=OUT;


	        end

        endfunction
      
        //SLR FUNCTION
        function [7:0] slr(input [7:0] DATA1,input [7:0] DATA2)  ;
        integer i,j;
          begin 
           for(j=7;j> 7-DATA2;j--)begin
               slr[j]=1'b0;
           end
           for(i=DATA2;i< 8;i++)begin
               slr[i-DATA2]=DATA1[i];
           end
          end

        endfunction
      
        //SRA FUNCTION
        function [7:0] sra(input [7:0] DATA1,input [7:0] DATA2)  ;
        integer i,j;
          begin 
           
           for(i=DATA2;i< 8;i++)begin
               sra[i-DATA2]=DATA1[i];
           end
           for(j=7;j> 7-DATA2;j--)begin
               sra[j]=sra[7-DATA2];
           end
          end

        endfunction

        //ROR FUNCTION
        function [7:0] ror(input [7:0] DATA1,input [7:0] DATA2)  ;
        
          begin 
          ror=OR(slr(DATA1,DATA2),sll(DATA1,8-DATA2));
           
          end

        endfunction 
        **/
       
            
         
          
           
        

         //ALWAYS WITH INPUTS
         always @(*)
	         begin

             
              //SELECT FUNCTION BY OPCODE
  	         	case(SELECT)
  	                	
                 3'b000:RESULT = FD_I  ;   //ASSIGN CALCULATION RESULT TO "RESULT " VARIABLE S 
                 3'b001:RESULT = ADD_I ;

                 3'b010:RESULT = AND_I ;
                 3'b011:RESULT = OR_I  ; 

              /**3'b100:begin #1;  RESULT=OUT1; $display(OUT1) ; end  //DELAY 1s AND DO SLL OPERATION

                 3'b101:begin #1;RESULT= slr(DATA1,DATA2); end  //DELAY 1s AND DO SLR OPERATION
                 3'b110:begin #1;RESULT= sra(DATA1,DATA2); end  //DELAY 1s AND DO SRA OPERATION
                 3'b111:begin #2;RESULT= ror(DATA1,DATA2); end  //DELAY 3s AND DO ROR OPERATION**/
                 default:///MADE DON'T CARE OUTPUT FOR RESERVED (NOT IMPLEMENTED) NO DELAY   
                        RESULT=8'bX;

              endcase 
              //SET ZERO FLAG
         ZERO=~|RESULT;  
                   
          end
             
             
                  
	         
endmodule
