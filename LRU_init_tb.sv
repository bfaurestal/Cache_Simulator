`include "LRU_init.sv"

module LRU_init_tb();

	uLRU_b_4 LRUb_4;
	uLRU_b_8 LRUb_8;
	bit [13:0] index;

initial
	begin
	index = 5;

	$display("Before initialize_LRU_b_4(), I-CACHE LRU[set][way]");
	$display("If the set is empty");

	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_4 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_4 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_4 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_4 [index][3]);
	
	LRUb_4 = initialize_LRU_b_4(index, LRUb_4);
	$display("After initialize_LRU_b_8()");
	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_4 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_4 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_4 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_4 [index][3]);
	
	$display("-------------------------------------------------");	
	$display("If the set is not empty");
	$display("Before initialize_LRU_b_4(), I-CACHE LRU[set][way]");
	$display("If the set is empty");
	index = 1024;

	LRUb_4 [index][0] = 2'b01;
	LRUb_4 [index][2] = 2'b11;
	LRUb_4 [index][1] = 2'b00;
	LRUb_4 [index][3] = 2'b10;

	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_4 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_4 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_4 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_4 [index][3]);
	
	LRUb_4 = initialize_LRU_b_4(index, LRUb_4);

	$display("After initialize_LRU_b_8()");
	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_4 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_4 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_4 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_4 [index][3]);

	$display("-------------------------------------------------");

	$display("Before initialize_LRU_b_8(), D-CACHE LRU[set][way]");
	$display("If the set is empty");
	index = 4096;
	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_8 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_8 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_8 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_8 [index][3]);
	$display("LRU[%0d][%0d] = %b", index, 4, LRUb_8 [index][4]);
	$display("LRU[%0d][%0d] = %b", index, 5, LRUb_8 [index][5]);
	$display("LRU[%0d][%0d] = %b", index, 6, LRUb_8 [index][6]);
	$display("LRU[%0d][%0d] = %b", index, 7, LRUb_8 [index][7]);

	LRUb_8 = initialize_LRU_b_8(index, LRUb_8);

	$display("After initialize_LRU_b_8()");
	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_8 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_8 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_8 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_8 [index][3]);
	$display("LRU[%0d][%0d] = %b", index, 4, LRUb_8 [index][4]);
	$display("LRU[%0d][%0d] = %b", index, 5, LRUb_8 [index][5]);
	$display("LRU[%0d][%0d] = %b", index, 6, LRUb_8 [index][6]);
	$display("LRU[%0d][%0d] = %b", index, 7, LRUb_8 [index][7]);


	$display("-------------------------------------------------");

	$display("Before initialize_LRU_b_8(), D-CACHE LRU[set][way]");
	$display("If the set is not empty");
	index = 8192;
	LRUb_8 [index][0] = 3'b111;
	LRUb_8 [index][1] = 3'b110;
	LRUb_8 [index][2] = 3'b101;
	LRUb_8 [index][3] = 3'b100;
	LRUb_8 [index][4] = 3'b010;
	LRUb_8 [index][5] = 3'b011;
	LRUb_8 [index][6] = 3'b001;
	LRUb_8 [index][7] = 3'b000;

	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_8 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_8 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_8 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_8 [index][3]);
	$display("LRU[%0d][%0d] = %b", index, 4, LRUb_8 [index][4]);
	$display("LRU[%0d][%0d] = %b", index, 5, LRUb_8 [index][5]);
	$display("LRU[%0d][%0d] = %b", index, 6, LRUb_8 [index][6]);
	$display("LRU[%0d][%0d] = %b", index, 7, LRUb_8 [index][7]);

	LRUb_8 = initialize_LRU_b_8(index, LRUb_8);

	$display("LRU[%0d][%0d] = %b", index, 0, LRUb_8 [index][0]);
	$display("LRU[%0d][%0d] = %b", index, 1, LRUb_8 [index][1]);
	$display("LRU[%0d][%0d] = %b", index, 2, LRUb_8 [index][2]);
	$display("LRU[%0d][%0d] = %b", index, 3, LRUb_8 [index][3]);
	$display("LRU[%0d][%0d] = %b", index, 4, LRUb_8 [index][4]);
	$display("LRU[%0d][%0d] = %b", index, 5, LRUb_8 [index][5]);
	$display("LRU[%0d][%0d] = %b", index, 6, LRUb_8 [index][6]);
	$display("LRU[%0d][%0d] = %b", index, 7, LRUb_8 [index][7]);
	end
endmodule
