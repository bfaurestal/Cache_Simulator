module update_LRU(block_select, LRU_bits, returned);

parameter integer a_size = 8;



output reg [a_size - 2 : 0]returned;

input [a_size - 2 : 0] LRU_bits;
input [$clog2(a_size) - 1 : 0] block_select;

int i = 0;
int a = 0;
int b = 0;
int enable = 0;

reg [a_size - 2 : 0]temp;
reg [a_size - 2 : 0]final_value;

//assign temp[a] = block_select[$clog2(associativity) - 1 - i];
//assign returned = temp;


always @(*)
begin
	while(block_select[0] === 1'bz || block_select[0] === 1'bx)
	begin
		#1;
	end
	a = 0;
	b = 0;
	returned = 0;

	for(i = 0; i < a_size - 1; i = i + 1)
	begin
		if(i == a)
		begin
			//$display("I made it here.");
			returned[i] = block_select[$clog2(a_size) - 1 - b];
			if(block_select[$clog2(a_size) - 1 - b]%2 == 0)
			begin
				a = 2 * a + 1;
			end
		
			else
			begin
				a = 2 * a + 2;
			end
			b = b + 1;
		end

		else if(LRU_bits[i] === 1'bx /*|| block_select[a] === 1'bx*/)
		begin
			returned[i] = 0;
		end

		/*else if(i == a)
		begin
			//$display("I made it here.");
			returned[i] = block_select[$clog2(a_size) - 1 - b];
			if(block_select[$clog2(a_size) - 1 - b]%2 == 0)
			begin
				a = 2 * a + 1;
			end
		
			else
			begin
				a = 2 * a + 2;
			end
			b = b + 1;
		end*/
			
		else
		begin
			returned[i] = LRU_bits[i];
		end
			
	end

end 




endmodule



 
