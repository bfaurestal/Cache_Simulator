
// Return type as 2 LRU bits for 4 ways, and 3 LRU bits for 8 ways
// -> LRU[sets][ways]
typedef bit[1:0] uLRU_b_4_1;
typedef uLRU_b_4_1 uLRU_b_4[16384][4];

typedef bit[2:0] uLRU_b_8_1;
typedef uLRU_b_8_1 uLRU_b_8[16384][8];


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




