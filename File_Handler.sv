import mypkg::*;

module File_Handler;

integer data_file;
integer valid_data;
integer data_command;
string retrieved_file;

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
		if((debug == 1 || normal == 1) && data_command != 9)
			begin
				$display("Command:%d at address %h ", data_command,read_address);
			end
		if(debug==1)
		begin
			$display("---->File_Handler.sv<----");
			$write("TAG_BITS:%d |",TAG_BITS);
			$write("INDEX_BITS:%d |",INDEX_BITS);
			$display("OFFSET_BITS:%d",OFFSET_BITS);
			$write("tag : %d |", tagg);
			$write("index : %d |", Index);
			$display("byselect : %b", offset);
		end
		
	end
	eof=1;
	#10
	if(debug==1)
		print_statistics;
	//
	//$finish;
end

task print_statistics;

	$display("Read:%d | Write:%d | Hit:%d | Miss:%d",read,write,hit,miss);

endtask

/* final begin
	$display("*******Data Cache Statistics");
	hit_ratio= hit/(hit+miss);
	$display("STATSITICS:");
	$display("CACHE READS|CACHE WRITES|CACHE HITS|CACHE MISSES|CACHE HIT RATIO");
	$display("%d	|\t%d |\t%d	|\t%d	|%f\t",read,write,hit,miss,hit_ratio );
end */



endmodule