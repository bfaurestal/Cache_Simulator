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
reg [1:0] mesi_state;
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

/**************M&I*********************************************/
typedef bit[1:0] uLRU_b_4_1;
typedef uLRU_b_4_1 uLRU_b_4[SET][4];

typedef bit[2:0] uLRU_b_8_1;
typedef uLRU_b_8_1 uLRU_b_8[SET][8];

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

always @(read_address )
//initial
begin
//#0
	//$display("Cnt: %d ", cnt);
	
case(cmd)

	READ: begin
		cache_read=cache_read+1;
		hit_or_miss(index, tag, empty_way, flag);
		
		if(flag==1) begin //it's a hit 
			
			//update MESI to invalidate at that index and way 
			$display("HIT for %h",tag);
			cache_hit++;
			which_way(index,empty_way);
			$display("this is the empty way %d",empty_way);
			//MESI_tracker[index][empty_way]=3;
			
		end
		else begin //it is a miss
			which_way(index,empty_way);
			//return the available way//
			// WhichWay8(index,
					// LRU_Returned);
			UpdateLRU(index,empty_way);
			dCache[index][empty_way] = tag;
			$display("updating %d",dCache[index][empty_way]);
			cache_miss++;
		end
		
		/********MESI*********/
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b10;
						//MESI_tracker[index][empty_way]=2;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b10;
						//MESI_tracker[index][empty_way]=2;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b11;
						//MESI_tracker[index][empty_way]=3;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b11;
						//MESI_tracker[index][empty_way]=3;
					
			end
		endcase
		/********MESI END*********/
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
		/********MESI*********/
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b01;
						//MESI_tracker[index][empty_way]=1;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b01;
						//MESI_tracker[index][empty_way]=1;
					

			end
			2'b10:
			begin
					
						mesi_state <= 2'b01;
						//MESI_tracker[index][empty_way]=1;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b11;
						//MESI_tracker[index][empty_way]=3;
					
			end
		endcase
	end

	I_FETCH: begin
		if(debug==1)
			$display("Inst fetch for address: %h",read_address);
		assign i_tag = read_address[ADDRESS_BITS - 1 : I_INDEX_BITS + OFFSET_BITS];//range for tag
		assign i_index = read_address[(OFFSET_BITS + I_INDEX_BITS) - 1:OFFSET_BITS]; //range for index
		assign i_byte_select = read_address[OFFSET_BITS - 1 : 0];//range for byte_select
		
		if(iCache[index][WAY]==i_tag) begin
			//set MESI state to E
			if(normal == 1 || debug ==1) begin
				$write("HIT #%d----",num);
				$write("HIT for tag %b----",i_tag);
				$display("at index %b",index);
			end
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
						//MESI_tracker[index][empty_way]=1;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b01;
						//MESI_tracker[index][empty_way]=1;
					

			end
			2'b10:
			begin
					
						mesi_state <= 2'b01;
						//MESI_tracker[index][empty_way]=1;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b11;
						//MESI_tracker[index][empty_way]=3;
					
			end
		endcase
		
		
	end

	L2_INVAL: begin
		if(debug==1)
			$display("--------->L2_INVALIDATE<---------");
		l2_invalidate(read_address);
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
		endcase

	end

	L2_DATA_RQ: begin
		$display("L2_DATA_RQ");
		case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
				
			end
			2'b01:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
		endcase
	end

	CLR: begin
		if(debug==1)
			$display("--------->CLEARING CACHE<---------");
		clear_cache;
			case (mesi_state)
			2'b00:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=00;
					
			end
			2'b01:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
			2'b10:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
			2'b11:
			begin
					
						mesi_state <= 2'b00;
						//MESI_tracker[index][empty_way]=0;
					
			end
		endcase
	end

	PRINT: begin
		if(debug)
			$display("--------->Printing comtents CACHE<---------");
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
	for(int i = 0; i< WAY; i++) begin
		dCache[1][i]=0;
		//dCache[1][i]=0;
		$display("dCache[0][%d],%d",i,dCache[1][i]);
		$display("dCache[0][%d],%d",i,dCache[7][i]);
	end 

endtask


/*
---------------->L2 Invalidate cache<-----------------
--Function to display upon an invalidate command--
*/
task l2_invalidate(input [32-1:0]read_address);
	$display("L2:  %h","Invalidate",read_address);
	//L2_control = FALSE;
endtask 

/* ---------------->Print Contents<-----------------
--Function display the contents of the cache upon a 9 command-- */
task print_contents;
$display("entering print_contents");
		for(int i = 0; i < index; i++) begin
			for(int i = 0; i < WAY; i++) begin
					//$display(" %s  	|  %d  	|  %d |  %h  | %d");
					$display("************ Valid lines in L1cache ************");
					$display(" MESI |  LRU  |  TAG 	|     SET    |  WAY");
					$display("  %b 	|  yd  	|  %d |  %h  | %d",MESI_tracker[index][i],valid_lines[index][i],index,i);
					
			end
		end
		$display("********************* END **********************");

endtask


/****************************************** Update LRU  *************************************
**Check way 0 to way 7 add current index
**update LRU of the cache
*/

task UpdateLRU(input reg[INDEX_BITS-1:0]LRU_index, 
				input int Lru_return_way);

	if(LRU_tracker[LRU_index][way]==0) begin 	//If LRU bits is MRU do nothing						
		return;
	end
	else begin 
		//curr_used = LRU_tracker[LRU_index][way];
		for(int i = 0; i < WAY; i = i + 1) begin
			if(LRU_tracker[LRU_index][i] < LRU_tracker[LRU_index][way]) 	begin		
				Lru_return_way = i;    			
				LRU_tracker[LRU_index][way]++;
				$display("LRU_index:%d way:%d LRU_bits%d", LRU_index, way, LRU_tracker[LRU_index][way] );
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
task which_way(input reg[INDEX_BITS-1:0]which_index , 
			output int return_way);

	for(int i = 0; i < WAY; i++) begin
	
		//if(MESI = I) Invalidate;
	
	end 
	
	for(int i = 0; i < WAY; i++) begin
		//$display(" at index:%d way[%d]:%d",index,i,dCache[index][i]);
		if(debug )
			$display("VICTIM way id:d",return_way);
		//$display(" at index %b way[%d]:%d",index,i,dCache[index][i]);
		
		if(dCache[which_index][i] == WAY - 1) begin
			empty_way = TRUE;
			return_way = i; 
			$display("VICTIM way id:d",return_way);
			//return return_way;
		end
		
	end
	$display(" returning this way %d", return_way);
endtask
/***********************************************************************************************/

/****************************************** Check if it's a hit or a miss *************************************
**Check way 0 to way 7 and current index*
**If a hit return at what way the hit occurned
** if a miss set Flag
*/

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
			///store valid lines//
			valid_lines[index][way_hit]=tag;
			MESI_tracker[index][way_hit]=mesi_state; // update mesi to shared
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

/***********************************************************************************************/


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
	for (i = 0; i < 8; i = i+1)
    	begin 
		// If any other ways are more than selected way
		// Decrement the other ways
        	if (LRU_b_8[index_8][way_8] < LRU_b_8[index_8][i])
			LRU_b_8[index_8][i] = LRU_b_8[index_8][i] - 1;
    	end
	
	// Set as MRU (111)
	LRU_b_8[index_8][way_8] = 3'b111;

	return LRU_b_8;
endfunction







/**************************************************END M&I*********************************************/





/***********************************************************************************************/

/* --------------->Print Statistics<--------------- */
final begin
	$display("*******Data Cache Statistics*******");
	hit_ratio= cache_hit/(cache_hit+cache_miss);
	$display("STATISTICS:");
	$display("CACHE READS|CACHE WRITES|CACHE HITS|CACHE MISSES|CACHE HIT_RATIO");
	$display("%d	|\t%d	|\t%d	|\t%d	|%f\t",cache_read,cache_write,cache_hit,cache_miss,hit_ratio );
	//$display("fake_read %d",fake_read);
	for(int i = 0; i< WAY; i++) begin
		$display("value in dCache[0][%d],%d",i,dCache[0][i]);
		$display("dCache[1][%d],%d",i,dCache[1][i]);
		//$display("MESI state:%d",MESI_tracker[1][i]);
	end 
	//$display("stack %p", LRU_tracker);
end

endmodule
