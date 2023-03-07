module update_LRU(block_sel_4, block_sel_8, LRU_b_4, LRU_b_8, up_LRU_b_4, up_LRU_b_8);

output reg [$clog2(4) - 1: 0] up_LRU_b_4;
output reg [$clog2(8) - 1: 0] up_LRU_b_8;

input [$clog2(4) - 1: 0] LRU_b_4;
input [$clog2(8) - 1: 0] LRU_b_8;

input [4 - 1: 0] block_sel_4;
input [8 - 1: 0] block_sel_8;

reg [$clog2(4) - 1: 0] LRU_b_4_temp;
reg [$clog2(8) - 1: 0] LRU_b_8_temp;

reg [$clog2(4) - 1: 0] LRU_b_4_final;
reg [$clog2(8) - 1: 0] LRU_b_8_final;

int i = 0;
int j = 0;

always @(block_sel_4, LRU_b_4)
begin
    for (i = 0; i < block_sel_4; i = i+1)
    begin 
        for (j = 0; j < $clog2(4) - 1; j = j+1)
        begin
            // Check if empty
            if (block_sel_4...)

            // Access 


