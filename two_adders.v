`timescale 1ns/100ps

//ADDER TO COUNT THE ADDITIONAL PART
module adder_4(PC,PC4);
input [31:0] PC;
output  [31:0] PC4;

assign  #1 PC4=PC+32'd4;//ADD 4 TO PC
endmodule

//J,BEQ,BNE ADDER
module shift_adder(SHIFTS,OFFSET);
input [7:0] SHIFTS;//INPUT SHIFTS
output reg [31:0] OFFSET;//OUTPUT OFFSET CALCULATED

    always@(SHIFTS)//CHANGE WITH SHIFT SIGNAL
    begin
       if(SHIFTS)
       #2;OFFSET=$signed({SHIFTS,2'b00});//CALCULATE OFFSET
    end
endmodule