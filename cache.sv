import mypkg::*;

module cache(read_address, 
				cmd, 
				cache_read,
				cache_write,
				cache_hit,
				cache_miss);

input		   [32-1:0] read_address;
input reg  [2: 0]cmd;
output int cache_write;
output int cache_read;
output int cache_hit;
output int cache_miss;
int count = 0;
reg [1:0]eof;

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
		 end
		 WRITE:
		 begin
		 cache_write++;
		 $display("cache_write: %d", cache_write);
		 end
	endcase
	$display(" -------From cahce----------");
	$display("CMD: %d", cmd);
	$display("Address %x",read_address);
	
	//$display("cache_read: %d", cache_read);
end









endmodule
