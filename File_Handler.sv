import mypkg::*;

module File_Handler;

integer data_file;
integer valid_data;
integer data_command;
string retrieved_file;
integer debug;
integer silent;
integer normal;
reg flag = 0;
reg[32-1:0] read_address;
reg [OFFSET_BITS - 1 : 0]offset;
reg [INDEX_BITS - 1 : 0]Index;
reg [TAG_BITS - 1: 0]tagg;

int read;
integer write;
integer miss; 
integer hit;
//reg [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];

address_parse inst (.address(read_address), 
					.tag(tagg),
					.index(Index),
					.byte_select(offset));
					
cache ch (.read_address(read_address), 
				.cmd(data_command), 
				.cache_read(read),
				.cache_write(write),
				.cache_hit(hit),
				.cache_miss(miss));
initial
begin
//look for file name
if($test$plusargs ("debug") || $test$plusargs ("d"))
	debug = 1;
if($value$plusargs ("f=%s", retrieved_file))
    $display("Received file name");
else
	begin
	$display("No file name received");
	$finish;
	end
//open file
//#0
data_file = $fopen(retrieved_file, "r");
if(data_file == 0)
	begin
	$display("Unable to open file");
	$finish;
	end
if($test$plusargs ("silent") || $test$plusargs ("s"))
	begin
	$display("silent mode");
	silent = 1;
	end
else
	begin
	$display("normal mode");
	normal =1;
	end


	while(!$feof(data_file))
	begin
	#10	valid_data = $fscanf(data_file, "%d", data_command);
	
		if(valid_data != 0)
			begin
			if(debug == 1)
			begin
				$display("Read command number: ", data_command);
				//$display("tag : ", data_command);
			end
			//send data into modules
			end
		else
			begin
			$display("No command read.");
			$finish;
			end

		valid_data = $fscanf(data_file, "%h", read_address);
		if(debug == 1)
			begin
				$display("Read Adress %h ", read_address);
			end
		if(debug==1)
		begin
			$display("----File_Handler.sv----");
			$write("TAG_BITS:%d |",TAG_BITS);
			$write("INDEX_BITS:%d |",INDEX_BITS);
			$display("OFFSET_BITS:%d",OFFSET_BITS);
			$write("tag : %b |", tagg);
			$write("index : %b |", Index);
			$display("byselect : %b", offset);
		end
		
	end
	#10
	print_statistics;
	//
	//$stop;
end

task print_statistics;

	$display("Read:%d | Write:%d | Hit:%d | Miss:%d",read,write,hit,miss);

endtask

/* always @(data_command, read_address)
begin
	if(valid_data != 0)
		begin
		if(normal == 1)
			begin
			$display("Read address: 0x%8h ", read_address);
			end
		if(debug == 1)
			begin
			$display("Read address: 0x%8h ", read_address);
			//busOps(data_command,read_address);
			
			$display("tagg: %16b",tagg);
			$display("Index: %b",Index);
			$display("byteselect: %b",offset);
			//$display ("------------cacheStruct---------------");
			//store_cache(tagg,Index,offset);

		//send data into modules
			end
		end
	else
		begin
		$display("No address read.");
		$finish;
		end
		
	//#10
$fclose(data_file);
end */
	
endmodule