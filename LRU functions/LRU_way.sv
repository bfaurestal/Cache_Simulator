// Return type as 2 LRU bits for 4 ways, and 3 LRU bits for 8 ways
// -> LRU[sets][ways]
typedef bit[1:0] uLRU_b_4_1;
typedef uLRU_b_4_1 uLRU_b_4[16384][4];

typedef bit[2:0] uLRU_b_8_1;
typedef uLRU_b_8_1 uLRU_b_8[16384][8];

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


