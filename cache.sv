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
reg [1:0] mesi_state = 2'b00;
int icache_hit;
int icache_miss;
int icache_read;
int icache_write;
int tag_hit =0;
int tag_miss =0;
integer hit_way;
logic [MESI_BITS-1:0]Lru_return_way;

/* ---------------------------Split Cache into index tag and offset<--------------------------- */
assign tag = read_address[ADDRESS_BITS - 1 : INDEX_BITS + OFFSET_BITS];//range for tag
assign index = read_address[(OFFSET_BITS + INDEX_BITS) - 1:OFFSET_BITS]; //range for index
assign byte_select = read_address[OFFSET_BITS - 1 : 0];//range for byte_select

/**************M&I*********************************************/
typedef bit[1:0] uLRU_b_4_1;
typedef uLRU_b_4_1 uLRU_b_4[SET][4];

typedef bit[2:0] uLRU_b_8_1;
typedef uLRU_b_8_1 uLRU_b_8[SET][8];

uLRU_b_8 my_LRU_8;
uLRU_b_4 my_LRU_4;
int way_8;
int way_4;
real a;
real b;
real c;
real i_a;
real i_b;
real i_c;
/***********************************************************************************************/

bit [MESI_BITS:0]LRU_Returned;

/* logic [MESI_BITS-1:0] STATE[INDEX_BITS-1:0][WAYS-1:0];
logic [LRU_BITS-1:0] LRU[INDEX_BITS-1:0][WAYS-1:0];	
logic [TAG_BITS-1:0] TAG[INDEX_BITS-1:0][WAYS-1:0]; */
//logic [MESI_BITS-1:0] iCache[LINE][I_WAY-1:0];

/*for testing purposes only*/
/* bit [14:0] iCache[16][2];
bit [14:0] dCache[16][2]; */


/*
---------------------------------Commands and address handler------------------------
--inside this always block it's a case function that takes the command and check perform the 
--valid operations and increment the counter if it exist
--for example when there is a read the read counter get incremented 
*/

initial begin
	clear_cache; //clear cache
end

/* always @(cache_hit or cache_miss) begin
	hit_ratio =cache_hit/(cache_hit+cache_miss);
	hit_rate = $itor(hit_ratio);
	$display("ratio%f",hit_rate);
end */

always @(read_address )
//initial
begin
//#0
	//$display("Cnt: %d ", cnt);
	
case(cmd)

	READ: begin
	    
		cache_read=cache_read+1;
		hit_or_miss(index, tag, flag);
		
		if(flag==1) begin //it's a hit 
			
			//update MESI to invalidate at that index and way 
			if(debug)
				$display("HIT for %h",tag);
			cache_hit++;
			//MESI_tracker[index][empty_way]=3;
			
		end
		else begin //it is a miss
			cache_miss++;
		end
		mesi;
	end

	WRITE: begin
	
		cache_write++;
		my_LRU_8= initialize_LRU_b_8(index,my_LRU_8);
		way_8 = WhichWay8 (index,my_LRU_8);
		
		if(dCache[index][way_8]==tag) begin //if hit
			cache_hit++;
			
			//Update MESI HERE
		
		end
		if(dCache[index][way_8]==0) begin // if cache is empty
			//$display("Compulstry Miss");
			cache_miss++;
			dCache[index][way_8]=tag; //write cache
			//Update MEsi to Modified
		end
		else begin
			dCache[index][way_8]=tag;
			my_LRU_8=updateLRU_b_8(index,way_8, my_LRU_8);
	
		end
		if(debug==1)
			$display("cache_write: %d", cache_write); 
	end

	I_FETCH: begin
		icache_read++;
		
		if(debug==1)
			$display("Inst fetch for address: %h",read_address);
		assign i_tag = read_address[ADDRESS_BITS - 1 : I_INDEX_BITS + OFFSET_BITS];//range for tag
		assign i_index = read_address[(OFFSET_BITS + I_INDEX_BITS) - 1:OFFSET_BITS]; //range for index
		assign i_byte_select = read_address[OFFSET_BITS - 1 : 0];//range for byte_select
		
		my_LRU_4= initialize_LRU_b_4(index,my_LRU_4);
		way_4 = WhichWay4 (i_index,my_LRU_4);
		if(iCache[i_index][way_4]==0) begin
			i_miss++;
			iCache[i_index][way_4] = i_tag;
			my_LRU_4=updateLRU_b_4(i_index,way_4, my_LRU_4);
		end
		if(iCache[i_index][way_4]==i_tag) begin
			if(debug ==1) begin
				$write("HIT #%d----",num);
				$write("HIT for tag %b----",i_tag);
				$display("at index %b",index);
			end
			icache_hit++;
		end
		else begin
			my_LRU_4= initialize_LRU_b_4(index,my_LRU_4);
			way_4 = WhichWay4 (i_index,my_LRU_4);
			iCache[index][WAY]=i_tag;
			my_LRU_4=updateLRU_b_4(i_index,way_4, my_LRU_4);
		end
		if (debug == 1) begin
			$write("I_TAG_BITS:%d |",I_TAG_BITS);
			$write("I_INDEX_BITS:%d |",I_INDEX_BITS);
			$display("OFFSET_BITS:%d",OFFSET_BITS);
			$write("I_tag : %b", i_tag);
			$write("I_index : %d", i_index);
			$display("I_byselect : %b", i_byte_select);
		end
		
		mesi;
		
	end

	L2_INVAL: begin
		
		if(debug==1)
			$display("--------->L2_INVALIDATE<---------");
		$display("L2: Invalidate %h",read_address);
		mesi;

	end

	L2_DATA_RQ: begin
		$display("L2_DATA_RQ");
		mesi;
	end

	CLR: begin
		mesi;
		if(debug==1)
			$display("--------->CLEARING CACHE<---------");
		mesi;
		clear_cache;
		
	end

	PRINT: begin
		if(debug)
			$display("--------->Printing comtents CACHE<---------");
		print_contents;
	end

	default: $display("Invalid Command");

endcase

end


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
	icache_hit=0;
	icache_miss=0;
	icache_read=0;
	icache_write=0;		  

	   


endtask


/*
---------------->L2 Invalidate cache<-----------------
--Function to display upon an invalidate command--
*/


/* ---------------->Print Contents<-----------------
--Function display the contents of the cache upon a 9 command-- */
task print_contents;
	if(debug)
		$display("entering print_contents");
		for(int i = 0; i < index; i++) begin
			for(int i = 0; i < WAY; i++) begin
					//$display(" %s  	|  %d  	|  %d |  %h  | %d");
					$display("************ Valid lines in L1cache ************");
					$display(" MESI |  LRU  |  TAG 	|     SET    |  WAY");
					$display("  %b 	|  %b  	|  %d |  %h  | %d",MESI_tracker[index][i],my_LRU_8[index][i],valid_lines[index][i],index,i);
					
			end
		end
		$display("********************* END **********************");

endtask


/****************************************** Update LRU  *************************************
**Check way 0 to way 7 add current index
**update LRU of the cache
*/




/****************************************** Check if it's a hit or a miss *************************************
**Check way 0 to way 7 and current index*
**If a hit return at what way the hit occurned
** if a miss set Flag
*/

task hit_or_miss(input reg[INDEX_BITS-1:0]this_index,
				reg [TAG_BITS - 1: 0]this_tag,
				output int hit_flag);
				
		my_LRU_8= initialize_LRU_b_8(this_index,my_LRU_8);
		way_8 = WhichWay8 (this_index,my_LRU_8);
		
		if(dCache[this_index][way_8] === 0) begin
			hit_flag = 0; //cold miss
			dCache[this_index][way_8] = this_tag;
			my_LRU_8=updateLRU_b_8(this_index,way_8, my_LRU_8);
			
		end
		
		if(dCache[this_index][way_8] === this_tag) begin
			//....... and mesi is not invalid 
			if(debug==1)
				$display("We've got a hit for tag %d at index:%d way_hit:%d, miss_flag:%d",this_tag,this_index,way_8,miss_flag);
			//cache_hit++;
			///store valid lines//
			
			valid_lines[index][way_8]=tag;
			//MESI_tracker[index][way_8]=mesi_state; // update mesi to shared
			hit_flag = 1;
			if(debug) 
				$display(" hit status is %d",hit_flag);
			
		end 
	
		else begin 

				//$display("MISS");
				hit_flag = 0;
				my_LRU_8= initialize_LRU_b_8(this_index,my_LRU_8);
				if(debug) begin
					for(int i = 0; i< WAY; i++) begin
						$display("content at index %0d: way:%0d of cache %h",this_index,i, dCache[this_index][i]);
					end
				end
				way_8 = WhichWay8 (this_index,my_LRU_8);
				if(debug)begin
					$display("the way selected is %d", way_8);
					$display("the content of LRu_8 at set%d,way%d, content%b",this_index,way_8,my_LRU_8[this_index][way_8]);
				end
				dCache[this_index][way_8] = this_tag;
				if(debug) begin
					for(int i = 0; i< WAY; i++) begin
						$display("content at index %0d: way:%0d AFTER of cache %h",this_index,i, dCache[this_index][i]);
					end
				end
				
				my_LRU_8=updateLRU_b_8(this_index,way_8, my_LRU_8);
				if(debug)
					$display("Update of LRu_8 at set%d,way%d, content%b",this_index,way_8,my_LRU_8[this_index][way_8]);
			
		end
		
	//end


endtask

/***********************************************************************************************/

task mesi;

		/********MESI*********/
		case (cmd)
			I:
			begin
			if(debug)
				$display("entering invalid %b",mesi_state);
				if (cmd == 0 || cmd == 2) begin 
					mesi_state <= 2'b01; //state equal to shared
					MESI_tracker[index][empty_way]=1;
				end else if( cmd == 1) begin 
					mesi_state <= 2'b10; 
					MESI_tracker[index][empty_way]=2;
				end 
				else begin 
					mesi_state <= 2'b00;
					MESI_tracker[index][empty_way]=0;
				end
				
		
			end
			S:
			begin
			if(debug)
				$display("entering Shared %b",mesi_state);
				if (cmd == 0 || cmd == 2) begin 
					mesi_state <= 2'b01; //state equal to shared
					MESI_tracker[index][empty_way]=1;
					//MESI_tracker[index][empty_way]=2;
				end else if( cmd == 1) begin 
					mesi_state <= 2'b10; 
					MESI_tracker[index][empty_way]=2;
				end 
				else begin 
					mesi_state <= 2'b00;
					MESI_tracker[index][empty_way]=0;
				end
				
		
			end
			E:
			begin
				if(debug)
					$display("entering Exclusive %b",mesi_state);
				if (cmd == 0 || cmd == 2) begin 
					mesi_state <= 2'b10; //state equal to Exclusive
					MESI_tracker[index][empty_way]=2;
				end else if( cmd == 1) begin 
					mesi_state <= 2'b11; 
					MESI_tracker[index][empty_way]=3;
				end 
				else begin 
					mesi_state <= 2'b00;
					MESI_tracker[index][empty_way]=0;
				end
				
		
			end
			M:
			begin
				if(debug)
					$display("entering Modified %b",mesi_state);
				if (cmd == 0 || cmd == 2 || cmd == 1) begin 
					mesi_state <= 2'b11; //state equal to shared
					MESI_tracker[index][empty_way]=3;
				end
				else begin 
					mesi_state <= 2'b00;
					MESI_tracker[index][empty_way]=0;
				end
				
		
			end
		endcase
		/********MESI END*********/


endtask
/*******************************************Mohammed and Ibrahim****************************************************/

// Return type as 2 LRU bits for 4 ways, and 3 LRU bits for 8 ways
// -> LRU[sets][ways]



// When instruction cache is never used before, this will initialize all values to the correct LRU bits 

function uLRU_b_4 initialize_LRU_b_4(bit [13:0] index_4, bit[1:0] LRU_b_4 [16384][4]);
	int i;
	int size;
	int number_of_0s;
	logic emptyflag;
	
	// Check the number of ways are present in the our set
	// If it was the instruction cache, we are going to have a total of 4 ways
	// if it was the data cache, we are going to have a total number of 8 ways
	size = $bits(LRU_b_4) /$size(LRU_b_4);
	size = size / $size(LRU_b_4[0][0]);

	
	// Count the number of ways that are actually set to 0
	for (i=0; i < size; i=i+1)
		begin
			if (LRU_b_4[index_4][i] == 0)
				number_of_0s++;
		end 

	// Compare if the variable number_of_0s is equal to the variable size
	// if so, set the empty flag
	// Note: that this indicates that the chosen set is empty
	if (number_of_0s  == size)
		emptyflag = 1;

	// The following section, checks the empty fla, if its equal to , we go through a loop and set the LRU bits accordingly
	if (emptyflag == 1)
	begin 
		for (i=0; i < (size-1); i=i+1)
			LRU_b_4[index_4][i+1] = LRU_b_4[index_4][i] + 1'b1;
	end

	// Clear empty flag
	emptyflag = 0;

	return LRU_b_4;
endfunction


function uLRU_b_8 initialize_LRU_b_8(bit [13:0] index_8, bit[2:0] LRU_b_8 [16384][8]);
	int i;
	int size;
	int number_of_0s;
	logic emptyflag;
	if(debug)
		$display("--------->initialinzing<--------------");
	// Check the number of ways are present in the our set
	// If it was the instruction cache, we are going to have a total of 4 ways
	// if it was the data cache, we are going to have a total number of 8 ways
	size = $bits(LRU_b_8) /$size(LRU_b_8);
	size = size / $size(LRU_b_8[0][0]);

	
	// Count the number of ways that are actually set to 0
	for (i=0; i < size; i=i+1)
		begin
			if (LRU_b_8[index_8][i] == 0)
				number_of_0s++;
		end 

	// Compare if the variable number_of_0s is equal to the variable size
	// if so, set the empty flag
	// Note: that this indicates that the chosen set is empty
	if (number_of_0s  == size)
		emptyflag = 1;

	// The following section, checks the empty fla, if its equal to , we go through a loop and set the LRU bits accordingly
	if (emptyflag == 1)
	begin 
		for (i=0; i < (size-1); i=i+1)
			LRU_b_8[index_8][i+1] = LRU_b_8[index_8][i] + 1'b1;
	end

	// Clear empty flag
	emptyflag = 0;

	return LRU_b_8;
endfunction

// Return type as 2 LRU bits for 4 ways, and 3 LRU bits for 8 ways
// -> LRU[sets][ways]

// returns the least recently used LRU bits for the 4-way intruction cache, Least recently used being 00

function int WhichWay4 (bit[13:0] index_4, bit[1:0] LRU_b_4 [16384] [4]);
	int i;
	int way;
// This for loop searches for least recently bits 00
		for (i = 0; i<4; i = i+1)
			begin 
				if (LRU_b_4[index_4][i] == 0)
				way = i;
			end
	return way;
endfunction
	


// returns the least recently used LRU bits for the 8-way data cache, Least recently used being 000

function  int WhichWay8 (bit[13:0] index_8, bit[2:0] LRU_b_8 [16384] [8]);
	int i;
	int way;
// This for loop searches for least recently bits 00
		for (i = 0; i<8; i = i+1)
			begin 
				if (LRU_b_8[index_8][i] == 0)
					way = i;
			end
	return way;	
	if(debug)
		$display("--------->returning %d<--------------",way);
endfunction



// Return type as 2 LRU bits for 4 ways, and 3 LRU bits for 8 ways
// -> LRU[sets][ways]


// Assuming LRU (00) and MRU (11)

function uLRU_b_4 updateLRU_b_4(bit [13:0] index_4, bit [1:0] way_4, bit[1:0] LRU_b_4 [16384][4]);
	int i;
	for (i = 0; i < 4; i = i+1)
    	begin 
		// If any other ways are more than selected way
		// Decrement the other ways
        	if (LRU_b_4[index_4][way_4] < LRU_b_4[index_4][i])
			LRU_b_4[index_4][i] = LRU_b_4[index_4][i] - 1;
    	end
	
	// Set as MRU (11)
	LRU_b_4[index_4][way_4] = 2'b11;
	
	return LRU_b_4;
endfunction

// Assuming LRU (000) and MRU (111)
function uLRU_b_8 updateLRU_b_8(bit [13:0] index_8, bit [7:0] way_8, bit[2:0] LRU_b_8 [16384][8]);
	int i;
	if(debug)
			$display("--------->before Updating %b<--------------",LRU_b_8[index_8][way_8]);
	for (i = 0; i < WAY; i = i+1)
    	begin 
		// If any other ways are more than selected way
		// Decrement the other ways
        	if (LRU_b_8[index_8][way_8] < LRU_b_8[index_8][i])
				LRU_b_8[index_8][i] = LRU_b_8[index_8][i] - 1;
    	end
	
	// Set as MRU (111)
	
	LRU_b_8[index_8][way_8] = 3'b111;
	if(debug)
		$display("--------->Updated LRU Bits:%b<--------------",LRU_b_8[index_8][way_8]);

	return LRU_b_8;
	if(debug)
		$display("--------->returnning LRU Bits:%p<--------------",LRU_b_8[1][WAY]);
endfunction


/**************************************************END M&I*********************************************/





/***********************************************************************************************/

/* --------------->Print Statistics<--------------- */
final begin
	$display("*******Data Cache Statistics*******");
	$display("STATISTICS:");
	$display("CACHE READS|CACHE WRITES|CACHE HITS|CACHE MISSES|CACHE HIT_RATIO");
	a = cache_hit;
	b = cache_miss;
	c = 100;
	hit_ratio = (a/(b+a))*c;
	$display("%d	|\t%d	|\t%d	|\t%d	|%0.3f\t",cache_read,cache_write,cache_hit,cache_miss,hit_ratio);
	$display("---------------------------------------------");
	$display("---------------------------------------------");
	$display("*******Instruction Cache Statistics*******");
	$display("STATISTICS:");
	$display("CACHE READS|CACHE WRITES|CACHE HITS|CACHE MISSES|CACHE HIT_RATIO");
	i_a = icache_hit;
	i_b = icache_miss;
	i_c = 100;
	ihit_ratio = (i_a/(i_b+i_a))*i_c;
	$display("%d	|\t%d	|\t%d	|\t%d	|%0.3f\t",icache_read,icache_write,icache_hit,icache_miss,ihit_ratio);
	
end

endmodule