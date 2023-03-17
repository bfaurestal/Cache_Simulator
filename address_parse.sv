import mypkg::*;

module address_parse(address, tag, index, byte_select);

//the defined size of an instruction
input [ADDRESS_BITS - 1: 0]address;

//the size of the output section arrays
output reg [OFFSET_BITS - 1 : 0]byte_select;
output reg [INDEX_BITS-1: 0]index;
output reg [TAG_BITS - 1 : 0]tag;
int cnt = 0;

assign byte_select = address[OFFSET_BITS - 1 : 0];//range for byte_select
assign index = address[(OFFSET_BITS+INDEX_BITS)-1:OFFSET_BITS]; //range for index
assign tag = address[ADDRESS_BITS - 1 : INDEX_BITS + OFFSET_BITS];//range for tag

/* 	$display("Cnt: %d ", cnt);
	$display(" -------From add_parse----------");
	$display("Address %x",address);
	$display("BYTE_SELKECT: %b", byte_select);
	$display ("INDEX: %b", index);
	$display ("TAG: %b", tag); */

endmodule
