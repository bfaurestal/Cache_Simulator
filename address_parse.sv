import mypkg::*;

module address_parse(address, tag, index, byte_select);
//parameters to be changed depending on the architecture (in bits used to represent them)
parameter integer i_size = 32;
parameter integer d_size = 6;
parameter integer c_size = 14;
parameter integer a_size = 8;

//the defined size of an instruction
input [ADDRESS_BITS - 1: 0]address;

//the size of the output section arrays
output reg [OFFSET_BITS - 1 : 0]byte_select;
output reg [INDEX_BITS-1: 0]index;
output reg [TAG_BITS - 1 : 0]tag;
int cnt = 0;

//assign different sections of the data to each output
//assign byte_select = address[d_size - 1 : 0];
//assign index = address[(c_size - $clog2(a_size) - d_size ) + d_size - 1 : d_size];
//assign tag = address[i_size - 1 : (c_size - $clog2(a_size)) + d_size];

always @(*)
begin
#0
	cnt = cnt +1;
	byte_select = address[OFFSET_BITS - 1 : 0];
	index = address[INDEX_BITS: d_size];
	tag = address[i_size - 1 : INDEX_BITS + OFFSET_BITS]; 
	$display("Cnt: %d ", cnt);
	$display(" -------From add_parse----------");
	$display("Address %x",address);
	$display("BYTE_SELKECT: %b", byte_select);
	$display ("INDEX: %b", index);
	$display ("TAG: %b", tag);
end

endmodule
