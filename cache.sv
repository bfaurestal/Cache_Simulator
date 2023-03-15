import mypkg::*;

module cache(read_address, 
				cmd, 
				cache_read,
				cache_write,
				cache_hit,
				cache_miss);

input		   [32-1:0] read_address;
input reg  [2: 0]cmd;
output real cache_write;
output int cache_read;
output real cache_hit;
output int cache_miss;
int count = 0;
int num = 0;
reg [1:0]eof;

/* logic [STATE_BITS-1:0] STATE[SETS-1:0][WAYS-1:0];
logic [LRU_BITS-1:0] LRU[SETS-1:0][WAYS-1:0];	
logic [TAG_BITS-1:0] TAG[SETS-1:0][WAYS-1:0]; */
//logic [MESI_BITS-1:0] iCache[LINE][I_WAY-1:0];
bit [14:0] iCache[16][2];
bit [14:0] dCache[16][2];


//`include "File_Handler.sv"
// File_Handler file (eof);
/* address_parse inst (.address(read_address), 
					.tag(tagg),
					.index( Index),
					.byte_select(offset_bits)); */
					
/* address_parse inst1 (.address(read_address), 
					.tag(tagg),
					.index( Index),
					.byte_select(offset_bits)); */
//$display(" -------Starting----------");
always @(read_address or cmd)
//initial
begin
//#0
	//$display("Cnt: %d ", cnt);
	
	case(cmd)
	
		 READ:
		 begin
		 cache_read=cache_read+1;
		 $display("cache_read: %d", cache_read);
		 if(tag[index] == tag) 
			 begin
			 $display("HIT");
			 end
		 
		 end
		 
		 WRITE:
		 begin
		 cache_write++;
		 $display("cache_write: %d", cache_write);
		 end
		 
		 I_FETCH:
		 begin
		 $display("Inst fetch");
		 end
		 
		 L2_INVAL:
		 begin
		 $display("L2_INVAL");
		 
		 end
		 
		 L2_DATA_RQ:
		 begin
		 $display("L2_DATA_RQ");
		 end
		 
		 CLR:
		 begin
		 $display("CLR");
		 
		 end
		 
		 PRINT:
		 begin
		 $display("PRINT");
		 end
		 
		 default: $display("Invalid Command");
		 
	endcase
	$display(" -------From cahce----------");

/* 	$display(" -------From cahce----------");
>>>>>>> Stashed changes
	$display("CMD: %d", cmd);
	$display("Address %x",read_address);
	 */
	//$display("cache_read: %d", cache_read);
end


initial
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
end






endmodule
