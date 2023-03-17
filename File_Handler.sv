import mypkg::*;

module File_Handler;

integer data_file; //address
integer valid_data;
integer data_command; //command
string retrieved_file; //file pointer

reg flag = 0;
reg[32-1:0] read_address;
reg [OFFSET_BITS - 1 : 0]offset;
reg [INDEX_BITS - 1 : 0]Index;
reg [TAG_BITS - 1: 0]tagg;

int read;
integer write;
integer miss; 
integer hit;
integer i_hit;
integer i_miss;
reg [1:0]eof;

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
if($test$plusargs ("debug") || $test$plusargs ("d")) begin
	debug = 1;
	$display("-------------->Debug mode on<------------");
end
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
else if(silent == 0 && debug ==0)
	begin
	$display("normal mode");
	normal =1;
	end


	while(!$feof(data_file))
	begin
	#1	valid_data = $fscanf(data_file, "%d", data_command);
	
		if(valid_data != 0) begin
			if(debug == 1)
				$display("Valid command command number: ", data_command);
			end
		else
			begin
			$display("No command read.");
			$finish;
			end
		
		valid_data = $fscanf(data_file, "%h", read_address);
		if((debug == 1 || normal == 1) && data_command != 9)
			begin
				$display("Command:%d at address %h ", data_command,read_address);
			end
					$display("tag : %d |", tagg);

	/* 	if(debug==1)
		begin
			$display("---->File_Handler.sv<----");
			$write("TAG_BITS:%d |",TAG_BITS);
			$write("INDEX_BITS:%d |",INDEX_BITS);
			$display("OFFSET_BITS:%d",OFFSET_BITS);
			write("tag : %d |", tagg);
			$write("index : %d |", Index);
			$display("byselect : %b", offset);
		end */
		
	end
	$fclose(data_file);
	//#10
	//if(debug==1)
		//print_statistics;
	//
	//$finish;
end



endmodule