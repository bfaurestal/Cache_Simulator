// Return type as 2 LRU bits for 4 ways, and 3 LRU bits for 8 ways
// -> LRU[sets][ways]
typedef bit[1:0] uLRU_b_4_1;
typedef uLRU_b_4_1 uLRU_b_4[16384][4];

typedef bit[2:0] uLRU_b_8_1;
typedef uLRU_b_8_1 uLRU_b_8[16384][8];


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