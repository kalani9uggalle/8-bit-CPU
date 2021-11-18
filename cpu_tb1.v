`include"two_adders.v"
`include"pc.v"
`include"alu.v"
`include"complement.v"
`include"cpu1.v"
`include"mux2x1.v"
`include"regfile.v"
`include"adder.v"
`include"dmem.v"
`include"cache.v"
`include"icache.v"
`include"imem.v"
`timescale 1ns/100ps
module tb;
      reg CLK,RESET;
      //PC
      wire [31:0] PC;
      //INSTRUCTION WORD
      wire [31:0] INSTRUCTION;
      //INSTRUCTION MEMORY REGISTER 8X1024
      reg  [7:0]INSTRUCTION_MEM [1023:0];
      //WIRES TO CONNECT CPU AND DATAMEMORY
      wire READ_MEM;
      wire WRITE_MEM;
      wire READ_CPU,WRITE_CPU,BUSY_CPU;
      wire BUSY;
      wire [7:0] ALU_RESULT,OUT1,MEM_OUT;
      wire [7:0] READ_DATA_CPU;
      wire [31:0] WRITE_DATA_MEM,READ_DATA_MEM;
      wire [5:0] ADDRESS_MEM;
      wire BUSY_COMBINED ;           //busywait signal combinational output of busy instruction cache and busy data cache 
       
      //WIRES THAT CONNECT ICACHE,CPU,IMEM
      wire [9:0] INADDRESS ;         //wire that inputs address of the instruction to the i.cache
      wire BUSYMEM ;                 //wire that connects busywait of i.memory to i.cache
      wire [127:0] READMEMDATA ;     //wire that inputs the data block fetched from i.memory to the i.cache
      wire READ;                     //wire that gives read signal from i.cache to i.memory
      wire [5:0] ADDRESSMEM;         //wire that gives address of the instruction that have to fetch from i.memory
      wire BUSY_CPU_I  ;             //wire that gives busysignal from i.cache to cpu


      
      assign BUSY_COMBINED = BUSY_CPU || BUSY_CPU_I ? 1:0 ; //either data memory busy or instruction mem busy
      assign INADDRESS =PC[9:0];            //instruction memory read by giving address of the instruction
    
      
      //CPU SET INPUTS OUTPUTS
      cpu mycpu(INSTRUCTION,CLK,RESET,READ_DATA_CPU,BUSY_COMBINED,PC,READ_CPU,WRITE_CPU,ALU_RESULT,OUT1);
       //cpu mycpu(INSTRUCTION,CLK,RESET,READ_DATA_CPU,BUSY_CPU,BUSY_CPU_I,PC,READ_CPU,WRITE_CPU,ALU_RESULT,OUT1);


      cache_mem  CMEM(CLK,RESET,READ_DATA_MEM,BUSY,READ_CPU,WRITE_CPU,ALU_RESULT,OUT1,READ_DATA_CPU,BUSY_CPU,READ_MEM,WRITE_MEM,ADDRESS_MEM,WRITE_DATA_MEM);

      //data main memory
      data_memory DMEM(CLK,RESET,READ_MEM,WRITE_MEM,ADDRESS_MEM,WRITE_DATA_MEM,READ_DATA_MEM,BUSY);
     
      //instruction cache
      cacheInstruction icache(CLK,RESET,INADDRESS,BUSYMEM,READMEMDATA,ADDRESSMEM,INSTRUCTION,BUSY_CPU_I,READ);
      
     // cheInstruction(CLK,RESET,INADDRESS,BUSYMEM,READMEMDATA,ADDRESSMEM,READWORD,BUSYCACHE,READ);
      

      //instruction memory
      data_memory1 imem(CLK,READ,ADDRESSMEM,READMEMDATA ,BUSYMEM );
  
      //INITIALISATION
      initial
      begin

         $dumpfile("reg_file_wavedata.vcd");
         //$dumpfile("cpu_wave.vcd");
         $dumpvars(0,tb);
         //$monitor($time," PC:%b, INSTRUCTION:%b",PC, INSTRUCTION[31:24]);

         CLK=1'b1;
         RESET=1'b0;
         #1
         RESET=1'b1;
         #5
         RESET=1'b0;


         //FINISH AFTER 500 TIME UNITS
         #10000
         $finish;

      end
        
      //CLK SIGNAL SET
      always
      #4 CLK=~CLK;

endmodule











