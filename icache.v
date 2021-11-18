`timescale 1ns/100ps

module cacheInstruction(CLK,RESET,INADDRESS,BUSYMEM,READMEMDATA,ADDRESSMEM,READWORD,BUSYCACHE,READ);

    input CLK,RESET;               //clk,reset signals from cpu
    input [9:0]   INADDRESS;       //address given into cache by cpu
    input [127:0] READMEMDATA ;    //read block from memory
    input BUSYMEM;                 //busywait signal from memory to cache
    output reg [5:0]  ADDRESSMEM;  //block adress given to the memory
    output reg [31:0] READWORD;    //word read from cache which gives to cpu
    output reg BUSYCACHE;          //busy signal sent to cpu
    output reg READ;               //read signal sent to memory

    reg  [127:0] ICACHE [7:0];     //cache memory register
    reg  [2:0]   TAG    [7:0];     //store tag values relevant to block
    reg  [7:0]   VALID ;           //store valid values relevant to block
    reg  [31:0]  SELECTWORD;       //instruction word selected from block in cache
    wire [2:0]   TAGADDRESS ;      //tag part of the address recieved to i.cache
    wire [2:0]   INDEXADDRESS  ;   //index part of the adress recieved to i.cache
    wire [3:0]   OFFSETADDRESS ;   //offset part of the adress recieved to i.cache
    wire [2:0]   TAGINDEX ;        //extract the tag relevant to index given block
    wire VALIDINDEX ;              //extract the valid bit  relevant to index given block
    wire [127:0] BLOCKINDEX ;      //extract the block relevant to index given 
    wire TAGCOMP ;                 //result of tag comparison
    wire HIT;                      //hit signal if hit -->1 else miss-->0
    reg READACCESS;                //enable cache reading
    //wire WORDINDEX  [31:0]  ;    //extract the word  relevant to index given block
    
    
    integer i;

    //at reset set i.cache ,valid bit,tag of blocks into zero
    //busycache set to zero at the beginning
    always@(RESET)begin
      if(RESET)begin
        for(i=0;i< 8;i++)begin
          ICACHE[i]=128'dx;
          TAG[i]=3'd0;
          VALID[i]=0;

        end
        BUSYCACHE=0;
    
      end
    end

    //if reset signal enabled in cache read must not be done.
    //always if reset enbled read stops
    always@(RESET)begin
      if(RESET)
        READACCESS=0;
    end
    
    //at every new pc value if reset disabled readaccess enabled
    always@(INADDRESS)begin
      if(!RESET)
        READACCESS=1;

    end
  
    //split the address into tag,index,offest
    assign TAGADDRESS    = INADDRESS[9:7];
    assign INDEXADDRESS  = INADDRESS[6:4];
    assign OFFSETADDRESS = INADDRESS[3:0];

    //extracting based on index
    assign #1 TAGINDEX      = TAG[INDEXADDRESS];
    assign #1 VALIDINDEX    = VALID[INDEXADDRESS];
    assign #1 BLOCKINDEX    = ICACHE[INDEXADDRESS];

    //tag comparison
    assign #1 TAGCOMP = (TAGINDEX==TAGADDRESS) ? 1:0 ;
    assign HIT=(TAGCOMP && VALIDINDEX) && READACCESS ;

    //select the word by the offset from the block
    always@(*)begin
      case(OFFSETADDRESS)
        4'b0000:begin #1  SELECTWORD = BLOCKINDEX[31:0] ;   end
        4'b0100:begin #1  SELECTWORD = BLOCKINDEX[63:32];   end
        4'b1000:begin #1  SELECTWORD = BLOCKINDEX[95:64];   end
        4'b1100:begin #1  SELECTWORD = BLOCKINDEX[127:96] ; end
      endcase
    end
    
    //if a hit and readaccess enabled selectword is assigned to readword(instruction word sends to cpu)
    //else if miss cpu stall begins and read signal enables
    always@(*)begin
      if(HIT && READACCESS)
        READWORD = SELECTWORD;
     
    end
    
    //at posedge clk if hit enabled after updating cache or original read access busycache signal disabled
    always@(posedge CLK)begin
     
      if(HIT==1)begin
        BUSYCACHE=0;
      
      end
    end


    /**fsm**/
    parameter IDLE = 3'b000, MEM_READ = 3'b001,WRITE_BLOCK=3'b010;
    reg [2:0] state, next_state;




    // combinational next state logic
    always @(*)
    begin
      case (state)
        //if not a hit then goes to memread in next posedge
        //else idle 
        IDLE:
            if (READACCESS && !HIT)  
                next_state = MEM_READ;
            else
                next_state = IDLE;
        
        //if busymem disabled in posedge ,then go to update cache with fetched block
        //else complete read
        MEM_READ:
            if (!BUSYMEM) 
                next_state = WRITE_BLOCK;
            else    
                next_state = MEM_READ;
       
        //update cpu after fetching a block
        WRITE_BLOCK:
            
            next_state = IDLE;
              
      endcase
    end


  // combinational output logic
    always @(*)
    begin
      case(state)
        IDLE:
          //if idle state memread set to zero
          begin  
            READ =0;
            ADDRESSMEM= 6'dx;  
          end
     
        MEM_READ: 
          //if memread memread signal set to 1
          //it enables busymem and then busycache
          begin
            READ = 1;
            ADDRESSMEM = {TAGADDRESS,INDEXADDRESS} ;
          end

        WRITE_BLOCK:
          //if memory read completed then this state updates cache
          //memread signal disabled 
          
          begin
            READ = 0;
            ADDRESSMEM =6'dx;
            
            //1 unit delay takes to writing operation
            //cache block,tag,valid updates
            #1
            ICACHE[INDEXADDRESS] = READMEMDATA ;
            TAG [INDEXADDRESS]  = TAGADDRESS ;
            VALID[INDEXADDRESS] =1;
         
          end

      endcase
    end

    // sequential logic for state transitioning 
    always @(posedge CLK, RESET)
    begin
        if(RESET)
          state = IDLE;
        else
          state = next_state;
    end

    /* Cache Controller FSM End */

    always@(*)begin
      if(BUSYMEM)
        BUSYCACHE = 1;
    end
    


endmodule


