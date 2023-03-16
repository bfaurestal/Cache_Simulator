`include "LRU_way.sv"

module WhichWay_tb();
	uLRU_b_4 LRUb_4;
	uLRU_b_8 LRUb_8;
	bit [13:0] set;
	int way_selected;
	int i;
	
	initial begin

	$display("Before WhichWay4(), I-CACHE LRU[set][way]");
	set = 776;
	$display("Selected set = %0d", set+1);

	$display("display the contents of the set selected, set %0d: ", set+1);
	LRUb_4[set][0] = 2'b10;
	LRUb_4[set][1] = 2'b01;
	LRUb_4[set][2] = 2'b00;
	LRUb_4[set][3] = 2'b11;
	for (i=0; i <4; i=i+1)
	$display("\t LRU[%0d][%0d] = %b", set+1, i+1, LRUb_4[set][i]);

	way_selected = WhichWay4(set, LRUb_4);
	$display ("The least recently used bits are in bits are at way %d", way_selected+1);
	$display ("Therefore, LRU[%0d][%0d] will be evicted", set+1, way_selected+1);
	

	$display("-------------------------------------------------");	
	$display("Before WhichWay4(), D-CACHE LRU[set][way]");
	set = 12163;
	$display("Selected set = %0d", set+1);

	$display("display the contents of the set selected, set %0d: ", set+1);
	LRUb_8 [set][0] = 3'b010;
	LRUb_8 [set][1] = 3'b100;
	LRUb_8 [set][2] = 3'b111;
	LRUb_8 [set][3] = 3'b110;
	LRUb_8 [set][4] = 3'b000;
	LRUb_8 [set][5] = 3'b011;
	LRUb_8 [set][6] = 3'b001;
	LRUb_8 [set][7] = 3'b101;
	for (i=0; i <8; i=i+1)
	$display("\t LRU[%0d][%0d] = %b", set+1, i+1, LRUb_8[set][i]);

	way_selected = WhichWay8(set, LRUb_8);
	$display ("The least recently used bits are in bits are at way %d", way_selected+1);
	$display ("Therefore, LRU[%0d][%0d] will be evicted", set+1, way_selected+1);

end
endmodule
