`include "updateLRU_func.sv"

module LRU_tb();

	uLRU_b_4 LRUb_4;
	uLRU_b_8 LRUb_8;
	
	bit [3:0] ways_4;
	bit [7:0] ways_8;

	bit [13:0] index;

initial
	begin
	index = 5;
	ways_4 = 3;
	ways_8 = 2;

	LRUb_4 [5][0] = 2'b01;
	LRUb_4 [5][2] = 2'b11;
	LRUb_4 [5][1] = 2'b00;
	LRUb_4 [5][3] = 2'b10;

	LRUb_8 [16383][0] = 3'b000;
	LRUb_8 [16383][1] = 3'b001;
	LRUb_8 [16383][2] = 3'b010;
	LRUb_8 [16383][3] = 3'b011;
	LRUb_8 [16383][4] = 3'b100;
	LRUb_8 [16383][5] = 3'b101;
	LRUb_8 [16383][6] = 3'b110;
	LRUb_8 [16383][7] = 3'b111;

	$display("Before updateLRU_b_4(), I-CACHE LRU[set][way]");
	$display("LRU[%d][%d] = %b", index, 0, LRUb_4 [index][0]);
	$display("LRU[%d][%d] = %b", index, 1, LRUb_4 [index][1]);
	$display("LRU[%d][%d] = %b", index, 2, LRUb_4 [index][2]);
	$display("LRU[%d][%d] = %b", index, 3, LRUb_4 [index][3]);
	
	LRUb_4 = updateLRU_b_4(index, ways_4, LRUb_4);

	$display("After updateLRU_b_4(), (Access to way = 3)");
	$display("LRU[%d][%d] = %b", index, 0, LRUb_4 [index][0]);
	$display("LRU[%d][%d] = %b", index, 1, LRUb_4 [index][1]);
	$display("LRU[%d][%d] = %b", index, 2, LRUb_4 [index][2]);
	$display("LRU[%d][%d] = %b", index, 3, LRUb_4 [index][3]);
	
	$display("-------------------------------------------------");

	$display("Before updateLRU_b_8(), D-CACHE LRU[set][way]");
	$display("LRU[%d][%d] = %b", 16383, 0, LRUb_8 [16383][0]);
	$display("LRU[%d][%d] = %b", 16383, 1, LRUb_8 [16383][1]);
	$display("LRU[%d][%d] = %b", 16383, 2, LRUb_8 [16383][2]);
	$display("LRU[%d][%d] = %b", 16383, 3, LRUb_8 [16383][3]);
	$display("LRU[%d][%d] = %b", 16383, 4, LRUb_8 [16383][4]);
	$display("LRU[%d][%d] = %b", 16383, 5, LRUb_8 [16383][5]);
	$display("LRU[%d][%d] = %b", 16383, 6, LRUb_8 [16383][6]);
	$display("LRU[%d][%d] = %b", 16383, 7, LRUb_8 [16383][7]);

	LRUb_8 = updateLRU_b_8(16383, ways_8, LRUb_8);

	$display("After updateLRU_b_8(), (Access to way = 2)");
	$display("LRU[%d][%d] = %b", 16383, 0, LRUb_8 [16383][0]);
	$display("LRU[%d][%d] = %b", 16383, 1, LRUb_8 [16383][1]);
	$display("LRU[%d][%d] = %b", 16383, 2, LRUb_8 [16383][2]);
	$display("LRU[%d][%d] = %b", 16383, 3, LRUb_8 [16383][3]);
	$display("LRU[%d][%d] = %b", 16383, 4, LRUb_8 [16383][4]);
	$display("LRU[%d][%d] = %b", 16383, 5, LRUb_8 [16383][5]);
	$display("LRU[%d][%d] = %b", 16383, 6, LRUb_8 [16383][6]);
	$display("LRU[%d][%d] = %b", 16383, 7, LRUb_8 [16383][7]);
	end
endmodule