module update_LRU_tb;

parameter integer a_size = 8;
integer i;
integer j;
integer k;
integer a = 0;

integer debug = 0;
//size of output and inputs
reg [a_size - 2 : 0] returned;
reg [a_size - 2 : 0] LRU_bits;
reg [$clog2(a_size) - 1 : 0] block_select;
reg [a_size - 2 : 0] check = 0;
reg [a_size - 2 : 0] temp = 0;

update_LRU #(.a_size(a_size)) test(block_select, LRU_bits, returned);


initial
begin
	if($test$plusargs ("debug")) //checking if debug was called in the terminal
		debug = 1;
	for(i = 0; i < a_size; i = i + 1)
	begin
		block_select = i; // set initial branch (very top of LRU tree) to the value of i
		for(j = 0; j < 2 ** (a_size-1); j = j + 1) //next branch of LRU tree
		begin
			LRU_bits = j;
			check = j;
			a = 0;
			for(k = 0; k < $clog2(a_size); k = k + 1) //final branch of LRU tree (the actual block)
			begin
				if(a > a_size-2) //if (a) is greater than the associativity, go to line 50
					break;
				check[a] = block_select[$clog2(a_size) - 1 - k]; //set the check[a] to the selected block value
				if(check[a] % 2 === 0) //if value is even
				begin
					a = 2 * a + 1; // go left
				end

				else //value must be odd
				begin
					a = 2 * a + 2; //go right
				end
			end
			//$display("Before delay: ", LRU_bits);
			#0;
			//$display("After delay: ", LRU_bits);
			if(returned !==  check || debug) //if the output value does not equal the check value or debug
			begin // display and compare the results to each other
				$displayb("\nblock select: ", block_select);
				$displayb("LRU bits: ", j);
				$displayb("should be: ", check);
				$displayb("Returned: ", returned);
			end
		end
	end
	$display("Finished.");
end


endmodule
