import mypkg::*;

module eviction_LRU(block_sel_8, block_sel_4, LRU_bits_8, LRU_bits_4);
parameter integer a_size_8 = 8;
parameter integer a_size_4 = 4;


input [$clog_2(a_size_8) * 8 - 1: 0]LRU_bits_8; // 24 bit
input [$clog_2(a_size_4) * 4 - 1: 0]LRU_bits_4; // 8 bit
//input [protocol - 1: 0] MESI[a_size_8];
//input [protocol - 1: 0] MESI[a_size_4];

output reg [$clog2(a_size_8) - 1 : 0]block_sel_8; //size of each block (based on log_2 calculation of associativity, log_2(8))
output reg [$clog_2(a_size_4) - 1 : 0]block_sel_4;

int i = 0;
int bit = 0;


// LRU with Counters:
//  8-Way Set Associative Data Cache:
//      -> log_2(8-Ways) = 3 bit/line
//      -> 3 bit/line x (8 line/set) = 24 bit/set
//  
//  4-Way Set Associative Instruction Cache:
//      -> log_2(4-Ways) = 2 bit/line
//      -> 2 bit/line x (4 line/set) = 8 bit/set
//  
//  For a Cache Miss:
//      Search for LRU bit 0 and Mark block/line with 0 to be evicted
//      
//      ELSE 


always @(LRU_bits_8)
begin
	for(i = 0; i < a_size_8; i = i + 1)
	begin

		block_sel_8[$clog2(a_size_8) - 1 - i] = LRU_bits_8[bit];
        
        if (LRU_bits_8[bit] === 0)
        begin
            block_sel_8[$clog2(a_size_8) - 1 - i] = 0;
        end

        else
        begin
            bit = bit + 1;
            block_sel_8[$clog2(a_size_8) - 1 - i] = LRU_bits_8[bit]; 
        end

		//if(LRU_bits[a] === 0) //if the selected block is even
		//begin
		//	block_select[$clog2(a_size) - 1 - i] = 1;
		//	a = 2 * a + 2; //go right
		//end
	
		//else // selected block must be odd
		//begin
		//	block_select[$clog2(a_size) - 1 - i] = 0;
		//	a = 2 * a + 1; // go left
		//end
			
		//if(MESI_8[i] === 0 || MESI_8[i][0] === 1'bx)
		//begin
		//	$display("MESI: ", MESI_8[i]);
		//	block_sel_8 = i;
		//	$display("block_select: ", block_sel_8);
		//	break;
		//end	
	end
end 

always @(LRU_bits_4)
begin

    for(i = 0; i < a_size_4; i = i + 1)
	begin

		block_sel_4[$clog2(a_size_4) - 1 - i] = LRU_bits_4[bit];
        
        if (LRU_bits_4[bit] === 0)
        begin
            block_sel_4[$clog2(a_size_4) - 1 - i] = 0;
        end

        else
        begin
            bit = bit + 1;
            block_sel_4[$clog2(a_size_4) - 1 - i] = LRU_bits_4[bit]; 
        end

        //if(MESI_4[i] === 0 || MESI_4[i][0] === 1'bx)
		//begin
		//	$display("MESI: ", MESI_4[i]);
		//	block_sel_4 = i;
		//	$display("block_select: ", block_sel_4);
		//	break;
		//end

    end
end
endmodule
