module update_LRU(index_4, way_4, index_8, way_8, LRU_b_4, LRU_b_8);

input [3:0] way_4;
input [7:0] way_8;

// [4 ways][2 bits]
// [8 ways][3 bits]
input int LRU_b_4 [3:0][$clog2(4) - 1: 0];
input int LRU_b_8 [7:0][$clog2(8) - 1: 0];

input [13: 0] index_4;
input [13: 0] index_8;

int i;

always @(index_4, way_4)
begin
    for (i = 0; i < 4; i = i+1)
    begin 
        if (LRU_b_4[index_4][i] < LRU_b_4[index_4][way_4])
		LRU_b_4[index_4][i] = LRU_b_4[index_4][i] + 1;
	
	LRU_b_4[index_4][way_4] = 0;
    end
end


always @(index_8, way_8)
begin
    for (i = 0; i < 8; i = i+1)
    begin 
        if (LRU_b_8[index_8][i] < LRU_b_8[index_8][way_8])
		LRU_b_8[index_8][i] = LRU_b_8[index_8][i] + 1;
	
	LRU_b_8[index_8][way_8] = 0;
    end
end

endmodule

