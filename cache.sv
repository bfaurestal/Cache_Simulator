
import mypkg::*;

module cache(read_address, 
				cmd, 
				cache_read,
				cache_write,
				cache_hit,
				cache_miss);

input		   [32-1:0] read_address;
input integer cmd;
output int cache_write;
output int cache_read;
output int cache_hit;
output int cache_miss;
int count = 0;
int num = 0;
reg [1:0] mesi_state;
reg [1:0]eof;

integer i_hit;
integer i_miss;

int tag_hit =0;
int tag_miss =0;
integer hit_way;
logic [MESI_BITS-1:0]Lru_return_way;

/* ---------------------------Split Cache into index tag and offset<--------------------------- */
assign tag = read_address[ADDRESS_BITS - 1 : INDEX_BITS + OFFSET_BITS];//range for tag
assign index = read_address[(OFFSET_BITS + INDEX_BITS) - 1:OFFSET_BITS]; //range for index
assign byte_select = read_address[OFFSET_BITS - 1 : 0];//range for byte_select

/************************************** CACHE MEMORY *******************************************/
logic [MESI_BITS-1:0] STATE[INDEX_BITS-1:0][WAY-1:0];
logic [MESI_BITS-1:0] LRU[INDEX_BITS-1:0][WAY-1:0];	
logic [TAG_BITS-1:0] TAG[INDEX_BITS-1:0][WAY-1:0];

/************************** Internal Variables ******************************/
logic [(TAG_BITS+INDEX_BITS)-1:0]trace_address;
logic [(TAG_BITS+INDEX_BITS)-1:0]evict_address;

/***********************************************************************************************/

/* logic [MESI_BITS-1:0] STATE[INDEX_BITS-1:0][WAYS-1:0];
logic [LRU_BITS-1:0] LRU[INDEX_BITS-1:0][WAYS-1:0];	
logic [TAG_BITS-1:0] TAG[INDEX_BITS-1:0][WAYS-1:0]; */
//logic [MESI_BITS-1:0] iCache[LINE][I_WAY-1:0];

/*for testing purposes only*/
/* bit [14:0] iCache[16][2];
bit [14:0] dCache[16][2]; */

/***********************************************************************************************/

assign trace_address = read_address[32-1:OFFSET_BITS];

assign req_set = read_address[OFFSET_BITS +: INDEX_BITS]; 			
assign req_tag = read_address[(INDEX_BITS + OFFSET_BITS) +: TAG_BITS];


assign hit_state = STATE[req_set][hit_way];


/*
---------------------------------Commands and address handler------------------------
--inside this always block it's a case function that takes the command and check perform the 
--valid operations and increment the counter if it exist
--for example when there is a read the read counter get incremented 
*/
initial
begin
	mesi_state = 2'b00;
end

always @(read_address or cmd)
//initial
begin
//#0
	//$display("Cnt: %d ", cnt);
	
case(cmd)

	READ: begin
		cache_read=cache_read+1;
		hit_or_miss(index, tag, empty_way, flag);
		
		if(flag==1) begin
			
			//$display("MISS");
			cache_hit++;
			which_way(empty_way);
			//MESI_tracker[index][empty_way]=3;
			
		end
		else begin
			cache_miss++;
		end
		case (mesi_state)
				2'b00:
				begin
					
						mesi_state <= 2'b01;
						MESI_tracker[index][empty_way]=1;
					
				end
				2'b01:
				begin
					
						mesi_state <= 2'b01;
						MESI_tracker[index][empty_way]=1;
					
				end
				2'b10:
				begin
					
						mesi_state <= 2'b01;
						MESI_tracker[index][empty_way]=1;
					
				end
				2'b11:
				begin
					
						mesi_state <= 2'b11;
						MESI_tracker[index][empty_way]=3;
				end
			endcase		
		end

	WRITE: begin
		cache_write++;
		if(dCache[index][WAY]==0) begin // if cache is empty
			//$display("Compulstry Miss");
			dCache[index][WAY]=tag; //write cache
			cache_miss++; //increment counter for miss
			/*
			Update MEsi to Modified
			*/
		end
		if(dCache[index][WAY]==tag) begin //if hit
			cache_hit++;
			/*
			Update MESI HERE
			*/
		
		end
		else begin
			dCache[index][WAY]=tag;
			
			/*
				LRU here 
			
			*/
		end
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b10;
						MESI_tracker[index][empty_way]=2;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b10;
						MESI_tracker[index][empty_way]=2;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b11;
						MESI_tracker[index][empty_way]=3;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b11;
						MESI_tracker[index][empty_way]=3;
					
			end
		endcase
		if(debug==1)
			$display("cache_write: %d", cache_write);

	end
	
	//end

	I_FETCH: begin
		if(debug==1)
			$display("Inst fetch for address: %h",read_address);
		assign i_tag = read_address[ADDRESS_BITS - 1 : I_INDEX_BITS + OFFSET_BITS];//range for tag
		assign i_index = read_address[(OFFSET_BITS + I_INDEX_BITS) - 1:OFFSET_BITS]; //range for index
		assign i_byte_select = read_address[OFFSET_BITS - 1 : 0];//range for byte_select
		
		if(iCache[index][WAY]==i_tag) begin
			//set MESI state to E
			$write("HIT #%d----",num);
			$write("HIT for tag %b----",i_tag);
			$display("at index %b",index);
			num++;
			i_hit++;
		end
		else begin
			iCache[index][WAY]=i_tag;
		end
		if (debug == 1) begin
		$write("I_TAG_BITS:%d |",I_TAG_BITS);
		$write("I_INDEX_BITS:%d |",I_INDEX_BITS);
		$display("OFFSET_BITS:%d",OFFSET_BITS);
		$write("I_tag : %b", i_tag);
		$write("I_index : %d", i_index);
		$display("I_byselect : %b", i_byte_select);
		end
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b01;
						MESI_tracker[index][empty_way]=1;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b01;
						MESI_tracker[index][empty_way]=1;
					

			end
			2'b10:
			begin
					
						mesi_state <= 2'b01;
						MESI_tracker[index][empty_way]=1;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b11;
						MESI_tracker[index][empty_way]=3;
					
			end
		endcase
		
	end

	L2_INVAL: begin
		$display("L2_INVAL");
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
		endcase
	end

	L2_DATA_RQ: begin
		$display("L2_DATA_RQ");
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
				
			end
			2'b01:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
		endcase
	end

	CLR: begin
		$display("CLR");
		clear_cache;
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=00;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b00;
						MESI_tracker[index][empty_way]=0;
					
			end
		endcase

	end

	PRINT: begin
		$display("PRINT");
		print_contents;
	end

	default: $display("Invalid Command");

endcase
/* 	$display(" -------From cahce----------");
	$display("CMD: %d", cmd);
	$display("Address %x",read_address);
	 */
	//$display("cache_read: %d", cache_read);
end


/* initial
begin
#100
	for(int i =0; i<10; i++) begin
		$display("array at position [%d]:at tag: %b",i,iCache[i][0]);
	end
	$display("iCache = %p", iCache);
	for(int i =0; i<10; i++)begin
		$display("---------DCACHE------------");
		$display("array at position [%d]:at tag: %b",i,dCache[i][0]);
	end
	$display("dCache = %p", dCache);
end */

/*
---------------->Clear cache<-----------------
--Function to clear cache by reset every to zero--
*/
task clear_cache;
	if(debug==1)
		$display("-----Clearing Cache--------");
	cache_read = 0;
	cache_hit = 0;
	cache_miss = 0;
	cache_write =0;

endtask


/*
---------------->L2 Invalidate cache<-----------------
--Function to display upon an invalidate command--
*/
task l2_invalidate(input [32-1:0]read_address);
	$display("L2: %s %h","Invalidate",read_address);
	$display("L2: %s %h","Invalidate",read_address);
	//L2_control = FALSE;
endtask 


/* --------------->Print Statistics<--------------- */
final begin
	$display("*******Data Cache Statistics*******");
	hit_ratio= cache_hit/(cache_hit+cache_miss);
	$display("STATISTICS:");
	$display("CACHE READS|CACHE WRITES|CACHE HITS|CACHE MISSES|CACHE HIT_RATIO");
	$display("%d	|\t%d	|\t%d	|\t%d	|%f\t",cache_read,cache_write,cache_hit,cache_miss,hit_ratio );
	//$display("fake_read %d",fake_read);
	/* for(int i = 0; i< WAYS; i++) begin
		
	end */
	//$display("stack %p", LRU_tracker);
end

/* ---------------->Print Contents<-----------------
--Function display the contents of the cache upon a 9 command-- */

task print_contents;

	for(int i = 0; i < index; i++) begin
		for(int i = 0; i < WAY; i++) begin
				//$display(" %s  	|  %d  	|  %d |  %h  | %d");
				$display("************ Valid lines in L1cache ************");
				$display(" MESI |  LRU  |  TAG 	|     SET    |  WAY");
				$display("  %b 	|  yd  	|  %d |  %h  | %d",MESI_tracker[index][i],dCache[index][i],index,i);
				
		end
	end
	$display("********************* END **********************");

endtask


/****************************************** Update LRU  *************************************
**Check way 0 to way 7 add current index
**update LRU of the cache
*/

task UpdateLRU(input index, input way);

	if(LRU_tracker[index][way]==0) begin 	//If LRU bits is MRU do nothing						
		return;
	end
	else begin 
		curr_used = LRU_tracker[index][way];
		for(int i = 0; i < WAY; i = i + 1) begin
			if(LRU_tracker[index][way] < curr_used) 	begin		
				Lru_return_way = i;    			
				LRU[index][i]= LRU[index][i] + 1'b1; 
				LRU_tracker[index][way]++;
			end			
		end	
	end
endtask



/****************************************** Get The Least recently used ***************************
**Check way 0 to way 7 and current index
***and return the unused way 
***or the least recenly used one
****
*/
task which_way(output return_way);

	for(int i = 0; i < WAY; i++) begin
	
		//if(MESI = I) Invalidate;
	
	end 
	
	for(int i = 0; i < WAY; i++) begin
		$display(" at index:%d way[%d]:%d",index,i,dCache[index][i]);
		if(normal==1 || debug == 1) begin
			//$display(" at index %b way[%d]:%d",index,i,dCache[index][i]);
			if(dCache[index][i] == WAY - 1) begin
				empty_way = TRUE;
				return_way = i; 
				$display("way %d",return_way);
				//return return_way;
			end
		end
	end
endtask
/***********************************************************************************************/

task hit_or_miss(input reg[INDEX_BITS-1:0]this_index,
				reg [TAG_BITS - 1: 0]this_tag, 
				output int way_filled,
				output int hit_flag);
				
				
		///$display("checking for tag[index:%d]=%d", this_index,this_tag);		
	for(int way_hit = 0; way_hit< WAY; way_hit++) begin 
		//$display("in here %dth time for tag:%d[index:%d]",way_hit,this_tag,this_index);
		if(dCache[this_index][way_hit] == this_tag) begin
			//....... and mesi is not invalid 
			if(debug==1)
			$display("We've got a hit for tag %d at index:%d way_hit:%d, miss_flag:%d",this_tag,this_index,way_hit,miss_flag);
			//cache_hit++;
			hit_flag = 1;
			way_filled = way_hit ; 
			$display("this is the way %d & hit status is %d", way_filled,hit_flag);
			
		end 
		else begin 
			if(dCache[this_index][way_hit] ==0) begin
			//$display("MISS");
			hit_flag = 0;
			dCache[this_index][way_hit] = this_tag;
			return;
			end
		end
	end


endtask

endmodule;
