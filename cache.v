`timescale 1ns/100ps
module cache_mem(CLK,RESET,READ_DATA_MEM,BUSY_MEM,READ_CPU,WRITE_CPU,ADDRESS_CPU,WRITE_DATA_CPU,READ_DATA_CPU,BUSY_CPU,READ_MEM,WRITE_MEM,ADDRESS_MEM,WRITE_DATA_MEM);
	input  [31:0] READ_DATA_MEM;      //read memory data [31:0]
	input  BUSY_MEM;                  //memory busy
	input  CLK,RESET;                 //clk,reset
	input  READ_CPU,WRITE_CPU;        //cpu read write signals
	input  [7:0] ADDRESS_CPU;         //address ->cpu
	input  [7:0] WRITE_DATA_CPU;      //write data word 
	output reg [7:0] READ_DATA_CPU;   //read data word
	output reg BUSY_CPU;              //busy cpu signal
	output reg READ_MEM,WRITE_MEM;    //read write signals memory
	output reg [5:0] ADDRESS_MEM;     //address->memory
	output reg [31:0] WRITE_DATA_MEM; //write memory data

	reg [31:0] CACHE_MEM [7:0] ;    //cache memory
	reg [2:0] TAG [7:0];            //holding tag relevant to index 2 x7 
	reg [7:0]  VALID;               //holding valid values 1x7
	reg [7:0]  DIRTY;               //holding dirty values 1 x7
	reg [2:0] TAG_ADDRESS;          //tag to corresponding address
	reg [2:0] INDEX;                //index part of address
	reg [1:0] OFFSET;               //offset part of address
	wire TAG_COMP_RESULT;           //tag comparison result
    reg [2:0] TAG_INDEX;            //tag corresponding to given index
    reg VALID_INDEX,DIRTY_INDEX;    //valid,dirty values corresponding to given index
    reg HIT;                        //hit signal
    reg EXTRACT_DATA_BLOCK;         //extract data block according to index 
    reg [7:0] CACHE_READ;           //read cache word relevant given index and offset
    //reg FETCH_DATA;               
    //reg READ_ACCESS,WRITE_ACCESS;
    wire [7:0] DATA_WORD;           //read cache word from select_word module
   

	integer i;

    //at the reset ==1 cache memory,tag,valid,dirty,busy_cpu is set to zero//
	always@(RESET)begin
	    if(RESET)begin
	        for(i=0;i<8;i++)begin
	            CACHE_MEM[i]=32'd0;
	            TAG[i]=2'd0;
	            VALID[i]=1'b0;
	            DIRTY[i]=1'b0;
	            BUSY_CPU=0;


	        end

	    end


	end

    //busy cpu becomes 1 at the first time read or write signals for cpu becomes 1//
    always @(READ_CPU ,WRITE_CPU)
	begin
	   BUSY_CPU=(READ_CPU || WRITE_CPU)? 1:0 ;
		
	end

    //always if memory busy cpu is also busy//
    always@(*)begin
       if(BUSY_MEM)
           BUSY_CPU=1;
    end

    //if address reached to cache adress divided into parts as tag ,index,offset//
	always@(ADDRESS_CPU)begin 
	   
	    TAG_ADDRESS=ADDRESS_CPU[7:5];
        INDEX=ADDRESS_CPU[4:2];
        OFFSET=ADDRESS_CPU[1:0];

    end

    //extracting block,tag,dirty,valid according to index 
    always@(*) begin
         if(READ_CPU|| WRITE_CPU)begin
	        #1  TAG_INDEX = TAG[INDEX];
	        EXTRACT_DATA_BLOCK=CACHE_MEM[INDEX];
	        DIRTY_INDEX = DIRTY[INDEX];
	        VALID_INDEX = VALID[INDEX];
	         
            //deciding hit by tag_comp_result by tag_comp module
	        HIT =TAG_COMP_RESULT && VALID_INDEX;
         end

	end

   
    //when read cpu enables data word is selected from cache before hit
	always@(*)begin
	    if(READ_CPU)
           CACHE_READ=DATA_WORD;
	end

    //after hit read value sent to cpu
	always@(*)begin
	    if(READ_CPU && HIT)
           READ_DATA_CPU=CACHE_READ;
	end

      

    //if write signal for cpu is enabled and a hit
    //values written to cache according to offset 
    always@(posedge CLK)begin
	    if(WRITE_CPU && HIT)
	        case(OFFSET)
	            2'b00: begin
	                   
			           #1 CACHE_MEM[INDEX][7:0]=WRITE_DATA_CPU;
			           VALID[INDEX]=1'b1;//valid is set to one 
			           DIRTY[INDEX]=1'b1;//dirty set to one
			           end
                2'b01:
                       begin
                      
			           #1 CACHE_MEM[INDEX][15:8]=WRITE_DATA_CPU;
			           VALID[INDEX]=1'b1;
			           DIRTY[INDEX]=1'b1;
			           end
	            2'b10:
                       begin
                   
			           #1 CACHE_MEM[INDEX][23:16]=WRITE_DATA_CPU;
			           VALID[INDEX]=1'b1;
			           DIRTY[INDEX]=1'b1;
			           end
			    2'b11:
                       begin
                       
			           #1 CACHE_MEM[INDEX][31:24]=WRITE_DATA_CPU;
			           VALID[INDEX]=1'b1;
			           DIRTY[INDEX]=1'b1;
			           end
        endcase   
	end

    //at posedge if hit busy cpu set to zero
	always@(posedge CLK)begin
	    if(HIT )begin
	    
	    	BUSY_CPU=0;
	    	
	    	
	    end
	    
	end
	
	



    /**fsm**/
    parameter IDLE = 3'b000, MEM_READ = 3'b001,MEM_WRITE=3'b010,CACHE_WRITE=3'b011;
    reg [2:0] state, next_state;




    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((READ_CPU|| WRITE_CPU) && !DIRTY_INDEX && !HIT)  
                    next_state = MEM_READ;
                else if ((READ_CPU|| WRITE_CPU) && DIRTY_INDEX && !HIT)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!BUSY_MEM) 
                    next_state = CACHE_WRITE;
                else    
                    next_state = MEM_READ;
            MEM_WRITE:
                if(!BUSY_MEM)
                    next_state = MEM_READ;
                else
                    next_state = MEM_WRITE;
            CACHE_WRITE://if cache write then set to next state
                
                    next_state = IDLE;
                
        endcase
    end




    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
	            begin
	                
	                READ_MEM=0;
	                WRITE_MEM = 0;
	                ADDRESS_MEM= 6'dx;
	                WRITE_DATA_MEM = 32'dx;
	                
	               
	            end
         
            MEM_READ: 
	            begin
	                READ_MEM = 1;
	                WRITE_MEM = 0;
	                ADDRESS_MEM = {TAG_ADDRESS,INDEX};
	                WRITE_DATA_MEM = 32'dx;
	                
	               

	            end

            MEM_WRITE:
                begin
	                READ_MEM = 0;
	                WRITE_MEM = 1;
	                ADDRESS_MEM = {TAG_INDEX,INDEX};
	                WRITE_DATA_MEM =CACHE_MEM[INDEX];//write  memory data cache block according to index

                
                end
            CACHE_WRITE:
	                begin
		                READ_MEM = 0;
		                WRITE_MEM = 0;
		               

		                ADDRESS_MEM =6'dx;
		                WRITE_DATA_MEM =32'dx;

		                #1 CACHE_MEM [INDEX]=READ_DATA_MEM;
				        VALID[INDEX]<=1'b1;
				      
				        DIRTY[INDEX]<=1'b0;
				       
				        TAG[INDEX]<=TAG_ADDRESS;
				      

	               
	                end

        endcase
    end

	tag_comp comparison(TAG_INDEX,TAG_ADDRESS,TAG_COMP_RESULT);//module to tag comparison
	select_word select_by_offset(CACHE_MEM[INDEX],OFFSET,DATA_WORD); //select word from a given block

	// sequential logic for state transitioning 
    always @(posedge CLK, RESET)
    begin
        if(RESET)
            state = IDLE;
        else
            state = next_state;
    end

    /* Cache Controller FSM End */

  endmodule













//module for tag comparison
module tag_comp(ARR1,ARR2,OUT);
    input [2:0] ARR1,ARR2;//two tags
    output reg OUT;       //if simillar output 1
	always@(*)
	begin
	    if(ARR1==ARR2)
	       #0.9 OUT=1'b1;//reduced tag comparison delay #1 ->0.9
	    else
	       #0.9 OUT=1'b0;
	end
endmodule

//select word from a given block
module select_word(DATA_BLOCK,OFFSET,DATA_WORD) ;
    
    input [31:0] DATA_BLOCK ;
    input [1:0]  OFFSET;
    output reg [7:0] DATA_WORD;

    always@(*)begin
        case(OFFSET)
            2'b00:#1 DATA_WORD<=DATA_BLOCK[7:0];
            2'b01:#1 DATA_WORD<=DATA_BLOCK[15:8];
            2'b10:#1 DATA_WORD<=DATA_BLOCK[23:16];
            2'b11:#1 DATA_WORD<=DATA_BLOCK[31:24];
        endcase
    end
endmodule

