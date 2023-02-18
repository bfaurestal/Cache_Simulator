import mypkg::*;

module File_Handler( eof);

integer data_file;
integer valid_data;
integer data_command;
string retrieved_file;
integer debug;
integer silent;
integer normal;
output reg eof;
reg flag = 0;
reg[32-1:0] read_address;
reg [OFFSET_BITS - 1 : 0]offset_bits;
reg [INDEX_BITS - 1 : 0]Index;
reg [TAG_BITS - 1: 0]tagg;
//reg [a_size + (protocol + i_size - c_size + a_size - d_size) * a_size - 2: 0] tag_array[2 ** (c_size - a_size)];

address_parse inst (.address(read_address), 
					.tag(tagg),
					.index( Index),
					.byte_select(offset_bits));

initial
begin
//look for file name
if($test$plusargs ("debug"))
	debug = 1;
if($value$plusargs ("f=%s", retrieved_file))
    $display("Received file name");
else
	begin
	$write("No file name received");
	$display(" Run: vsim +f=\"filename\" ");
	$finish;
	end
//open file
#0
data_file = $fopen(retrieved_file, "r");
if(data_file == 0)
	begin
	$display("Unable to open file");
	$finish;
	end
if($test$plusargs ("silent"))
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
	valid_data = $fscanf(data_file, "%d", data_command);
#5
	if(valid_data != 0)
		begin
		if(debug == 1)
			$display("Read command number: ", data_command);
		//send data into modules
		end
	else
		begin
		$display("No command read.");
		$finish;
		end

	valid_data = $fscanf(data_file, "%h", read_address);
//#1
	if(valid_data != 0)
		begin
		eof = 0;
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
			$display("byteselect: %b",offset_bits);
			//$display ("------------cacheStruct---------------");
			//store_cache(tagg,Index,offset_bits);
			$display("EOF %d",eof);
		//send data into modules
			end
			
		end
		
	else
		begin
		$display("No address read.");
		$finish;
		end
		
	end
	eof = 1;
	//#10
$fclose(data_file);
$display("EOF %d",eof);
end
	
endmodule