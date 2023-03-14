module mesi_protocol(clk, reset, first_read, r_w_s_i, detect);

input clk;
input reset;
input [1:0] r_w_s_i;
input first_read;
output reg detect;

reg [1:0] state;

initial
begin
	state = 2'b00;
end

always @(posedge clk, posedge reset)
begin
	if (reset)
		state <= 2'b00;
	else
	begin
		if (r_w_s_i == 2'b00) // In case of a write
			case (state)
				2'b00:
				begin
					state <= 2'b10;
				end
				2'b01:
				begin
					state <= 2'b10;
				end
				2'b10:
				begin
					state <= 2'b11;
				end
				2'b11:
				begin
					state <= 2'b11;
				end
			endcase
		else if (r_w_s_i == 2'b01)// In case of a read
			case (state)
				2'b00:
				begin
					if (first_read == 1'b1)
						state <= 2'b10;
					else
						state <= 2'b01;
				end
				2'b01:
				begin
					state <= 2'b01;
				end
				2'b10:
				begin
					state <= 2'b01;
				end
				2'b11:
				begin
					state <= 2'b11;	
				end
			endcase		
		else if (r_w_s_i == 2'b10)// In case of a snoop
			case (state)
				2'b00:
				begin
					state <= 2'b00;
				end
				2'b01:
				begin
					state <= 2'b00;
				end
				2'b10:
				begin
					state <= 2'b00;
				end
				2'b11:
				begin
					state <= 2'b00;	
				end
			endcase			
		else //invalid
			case (state)
				2'b00:
				begin
					state <= 2'b00;
				end
				2'b01:
				begin
					state <= 2'b00;
				end
				2'b10:
				begin
					state <= 2'b00;
				end
				2'b11:
				begin
					state <= 2'b00;	
				end
			endcase			
		end

end

always @(posedge clk, posedge reset)
begin
	if (reset)
		detect <= 0;
	else if (state == 2'b11)
		detect <= 1;
	else
		detect <= 0;
end

endmodule
