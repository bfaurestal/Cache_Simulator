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

bit [MESI_BITS-1:0]way_hit, way_miss, way_Lru_returned;
bit [MESI_BITS-1:0]Lru_set_prev[WAY];
bit [MESI_BITS-1:0]Lru_set_nxt[WAY];
bit [MESI_BITS-1:0]Lru_set_snp_prev[WAY];
bit [MESI_BITS-1:0]Lru_set_snp_nxt[WAY];
bit [32-1:0]trc_addr,evct_addr;

logic [INDEX_BITS-1:0]req_set; //offsetbits:0
logic [TAG_BITS-1:0]req_tag; //tagbits

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

always @(read_address or cmd)
//initial
begin
//#0
	//$display("Cnt: %d ", cnt);
	
case(cmd)

	READ: begin
		cache_read=cache_read+1;
		/* //check_ways;
		
		 if(dCache[index][WAY]==0) begin // if cache is empty
			$display("Compulstry Miss");
			dCache[index][WAY]=tag; //write cache
			cache_miss++; //increment counter for miss
		end
		//if(dCache[index][WAY]==tag) begin //if it's a hit
		which_way(empty_way);
		if(tag_hit) begin //if it's a hit
			cache_hit++; //tracks number of hits 
			if(normal==1) begin
				$write("HIT #%d----",num);
				$write("HIT for tag %b----",tag);
				$display("at index %d",index);
			end
			tag_hit =1;
			
		end
		else begin //if cache not empty or full
			cache_miss++;
			dCache[index][empty_way]=tag;
			//tag_miss=1;
		end
		task_LRU; */
		hit_or_miss(index, tag, empty_way, flag);
		
		if(flag==1) begin
			
			//update MESI to invalidate at that index and way 
			//$display("MISS");
			cache_hit++;
			which_way(empty_way);
			MESI_tracker[LINE][empty_way]=3;
			
		end
		else begin
			cache_miss++;
		end
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
		if(debug==1)
			$display("cache_write: %d", cache_write);
	eof = 0;
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
		
		
	end

	L2_INVAL: begin
		$display("L2_INVAL");

	end

	L2_DATA_RQ: begin
		$display("L2_DATA_RQ");
	end

	CLR: begin
		$display("CLR");
		clear_cache;
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

/*
---------------->UpdateLRU<-----------------
--Function for the Least Replacement Used--
--This function check which way is available--
--Also check if all the way is full and if full evicts the LRU--
 task UpdateLRU(input index, input way);
for(int i =0 ; i < WAY; i++) begin 
	if(LRU[index][i] < LRU[index][way])
		LRU[index][i]++;
LRU[index][way] = 0;


endtask
*/


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
				$display(" ys  	|  yd  	|  %d |  %h  | %d",tag,index,i);
				
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

/****************************************** CHECK CACHE *************************************
**Check way 0 to way 7 add current index
*/
/* task check_ways;
	tag_hit = FALSE;
	tag_miss = FALSE;
	for(int i = 0; i < WAY; i++) begin
	//$display(" at index %dway[%d]:%d",index,i,dCache[index][i]);
	if(normal==1 || debug == 1)
		$display(" at index %b way[%d]:%d",index,i,dCache[1][i]);
		if(dCache[index][i] == tag) begin
			tag_hit = TRUE;
			$display (":HIT# %d",tag_hit);
			tag_miss = FALSE; 
			hit_way = i;
			//$display("hit at:%d",index);
			if(normal==1);
				$display("hit at way[%d]:%d",i,index);
			//if(debug) tag_hit_res =(tag_hit);
			if(debug) way_hit=hit_way;
		end
	end
	if(tag_hit == FALSE) begin
		tag_hit = FALSE;
		tag_miss = TRUE;
	
		//if(debug) tag_miss_res =(tag_miss);
	end
endtask */
/***********************************************************************************************/


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

/****************************************** Check if it's a hit or a miss *************************************
**Check way 0 to way 7 and current index*
**If a hit return at what way the hit occurned
** if a miss set Flag
*/
task hit_or_miss(input this_index, input this_tag, output way_filled,output miss_flag);
	for(int way_hit = 0; way_hit< WAY; way_hit++) begin 
	
		if(dCache[this_index][way_hit] == this_tag) begin
			//....... and mesi is not invalid 
			if(debug==1)
				$display("We've got a hit for tag %d at index:%d way_hit:%d, miss_flag:%d",tag,index,way_hit,miss_flag);
			//cache_hit++;
			miss_flag = 1;
			way_filled = way_hit ; 
			break;
		end 
		else begin 
			$display("MISS");
			miss_flag = 0;
		end
	end


endtask

/***********************************************************************************************/

endmodule