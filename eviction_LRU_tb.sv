module eviction_lru_tb;

parameter integer assoc_8 = 8;
parameter integer assoc_4 = 4;

integer i;

integer debug = 0;

reg [$clog2(assoc_8) * 8 - 1: 0] ret_LRU_b_8;
reg [$clog2(assoc_8) * 8 - 1: 0] LRU_bits_8;
reg [$clog2(assoc_4) * 4 - 1: 0] ret_LRU_b_4;
reg [$clog2(assoc_4) * 4 - 1: 0] LRU_bits_4;

reg [$clog2(assoc_8) - 1: 0] chk_block_sel_8;
reg [$clog2(assoc_8) - 1: 0] block_sel_8;
reg [$clog2(assoc_4) - 1: 0] chk_block_sel_4;
reg [$clog2(assoc_4) - 1: 0] block_sel_4;

eviction_LRU e_LRU(block_sel_8, block_sel_4, LRU_bits_8, LRU_bits_4);

initial
begin
    for(int j = 0; j < 2**(assoc_           
