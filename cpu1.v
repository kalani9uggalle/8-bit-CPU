`timescale 1ns/100ps

//CPU MODULE
module cpu(INSTRUCTION,CLK,RESET,MEM_OUT,BUSY,PC,READ_MEM,WRITE_MEM,MEM_ADRESS,WRITE_DATA);

      //INITIALISE INPUT OUTPUT PORTS
      input  [31:0] INSTRUCTION;
      input CLK,RESET,BUSY;
      input [7:0] MEM_OUT;
      output  [31:0] PC;
      output reg READ_MEM,WRITE_MEM;
      output [7:0] MEM_ADRESS,WRITE_DATA;

          
      //REG DEFINE TO INSTATIATE MODULES
      reg [7:0] OPCODE,DES_REG,SRC1,SRC2,IMMEDIATE,SHIFTS;
      reg [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS,SELECT_OP;
      //SEND SIGNALS
      reg WRITE,MUX1,MUX2,J,BEQ,BNE,MUX3;
      //INCREMENTED PC VALUE //FOR CALCULTED SHIFT VALUE
      wire [31:0]  PC_OUT    ,ADD;
      //WIRES FOR OUTPUTS OF MODULE INSTATIATIONS
      wire [7:0] OUT1,OUT2,IN,COMP_OPERAND,MUX_1_OUT,MUX_2_OUT,ALU_RESULT;
      //OUTPUT IF ZERO FOR sub OPERATION
      wire ZERO;

      
     

      //ASSIGN INCREMENTED PC VALUE TO PC
      assign PC=PC_OUT;

      //AT NEW INSTRUCTION DECODE INSTRUCTION
      always@(INSTRUCTION)
      begin
       
          //DECODE DELAY
          //DECODE

          //IMMEDIATE
          IMMEDIATE   = INSTRUCTION[7:0];
          SHIFTS      = INSTRUCTION[23:16];
          INADDRESS   = INSTRUCTION[18:16];
          OUT1ADDRESS = INSTRUCTION[10:8];
          OUT2ADDRESS = INSTRUCTION[2:0];
          OPCODE      = #1 INSTRUCTION[31:24];
          
          READ_MEM=1'b0;
          WRITE_MEM=1'b0;
     

      
          //ACCORDING TO OPCODES SEND SIGNALS
          case(OPCODE)
                        //loadi//
          8'b00000000:begin
                        SELECT_OP=3'b000;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //MUX1 IS DISABLED
                        MUX1 =1'bx;
                        //MUX2 SELECT OPERAND1
                        MUX2 =1'b0;

                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b0;

                        
                      end
                      
                        //mov//
          8'b00000001:begin
                        SELECT_OP=3'b000;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //OPERAND1 IN MUX1
                        MUX1 =1'b0;
                        //OPERAND2 IN MUX2
                        MUX2 =1'b1;

                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b0;
                   
                      end
                      
                        //add//
          8'b00000010:begin
                        SELECT_OP=3'b001;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //OPERAND1 IN MUX1
                        MUX1 =1'b0;
                        //OPERAND2 IN MUX2
                        MUX2 =1'b1;

                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b0;
                      
                      end

                        //sub//
          8'b00000011:begin
                        SELECT_OP=3'b001;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //SELECT OPERAND2 IN MUX1(NEGATIVE)
                        MUX1 =1'b1;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b1;

                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b0;
                      
                      end

                        //and//
          8'b00000100:begin
                        SELECT_OP=3'b010;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //SELECT OPERND1 IN MUX1
                        MUX1 =1'b0;
                        //SELECT OPERND2 IN MUX2
                        MUX2 =1'b1;

                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b0;
                    
                      end

                        //or//
          8'b00000101:begin
                        SELECT_OP=3'b011;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //SELECT OPERAND1 IN MUX1
                        MUX1 =1'b0;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b1;

                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b0;
                      end
                      
                        //j//
          8'b00000110:begin
                        
                        SELECT_OP=3'b000;

                        //WRITE DISABLE
                        WRITE=1'b0;
                        //SELECT IN MUX1 DON'T CARE
                        MUX1 =1'bx;
                        //SELECT IN MUX2 DON'T CARE
                        MUX2 =1'bx;
                        //j OPERATION SIGNAL ENABLE
                        J=1'b1;
                        //beq OPERATION SIGNAL DISABLE
                        BEQ=1'b0;
                        //bne OPERATION SIGNAL DISABLE
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'bx;
                      end
                       //beq//
          8'b00000111:begin
                       
                        SELECT_OP=3'b001;

                        //WRITE DISABLE
                        WRITE=1'b0;
                        //SELECT OPERAND2 IN MUX1
                        MUX1 =1'b1;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b1;
                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b1;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'bx;
                      end
        
          8'b00001001 :begin
                        //lwi
                        SELECT_OP=3'b000;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //SELECT OPERAND1 IN MUX1
                        MUX1 =1'bx;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b0;
                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b1;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b1;

                      end

        8'b00001100: begin
                        //bne
                        SELECT_OP=3'b001;

                        //WRITE DISABLE
                        WRITE=1'b0;
                        //SELECT OPERAND2 IN MUX1
                        MUX1 =1'b1;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b1;
                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b1;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'bx;
                      end  
        8'b00001000 :begin
                        //lwd

                        SELECT_OP=3'b000;

                        //WRITE ENABLE
                        WRITE=1'b1;
                        //SELECT OPERAND1 IN MUX1
                        MUX1 =1'b0;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b1;
                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b1;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'b1;

                        
                      end
          8'b00001010 :begin
                        //swd
                         SELECT_OP=3'b000;

                        //WRITE DISABLE
                        WRITE=1'b0;
                        //SELECT OPERAND1 IN MUX1
                        MUX1 =1'b0;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b1;
                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b1;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'bx;
                      end
          8'b00001011 :begin
                        //swi
                        SELECT_OP=3'b000;

                        //WRITE DISABLE
                        WRITE=1'b0;
                        //SELECT OPERAND1 IN MUX1
                        MUX1 =1'bx;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'b0;
                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //IF READ MEMORY
                        READ_MEM=1'b0;
                        //IF WRITE MEMORY
                        WRITE_MEM=1'b1;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'bx;
                      end
          default     :begin
                        //DEFAULT INSTRUCTION
                        SELECT_OP=3'bx;

                        //WRITE DISABLE
                        WRITE=1'bx;
                        //SELECT OPERAND2 IN MUX1
                        MUX1 =1'bx;
                        //SELECT OPERAND2 IN MUX2
                        MUX2 =1'bx;
                        //IF j OPERATION
                        J=1'b0;
                        //IF beq OPERATION
                        BEQ=1'b0;
                        //IF bne OPERATION
                        BNE=1'b0;
                        //SELECT IN VALUE FOR REGISTER
                        MUX3=1'bx;
                      end
            
          endcase
     
      end

      //INSTANTIATE reg_file()
      reg_file myreg(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET,BUSY);

      //INSTANTIATE 2'S COMPLEMENT comp()
      comp neg(OUT2,COMP_OPERAND);

      //INSTANTIATE MUX1 mux2x1()
      mux2x1 mux1(MUX1,OUT2,COMP_OPERAND,MUX_1_OUT);

      //INSTANTIATE MUX2 mux2x1()
      mux2x1 mux2(MUX2,IMMEDIATE,MUX_1_OUT,MUX_2_OUT);

      //INSTANTIATE ALU alu()
      alu myalu( OUT1,MUX_2_OUT, SELECT_OP,ALU_RESULT,ZERO);
      //CALCULATE THE SHIFT VALUE FOR J,BEQ 
      add myadder(SHIFTS,J,BEQ,BNE,ZERO,ADD);
      //CU TO SET THE PC VALUE
      cu mycu(PC,ADD,CLK,RESET,BUSY,PC_OUT);


      //INSTANTIATE MUX3 mux2x1()
      mux2x1 mux3(MUX3,ALU_RESULT,MEM_OUT,IN);
      
      //
      
      assign MEM_ADRESS=ALU_RESULT;
      assign WRITE_DATA=OUT1;


endmodule

