module mesi_protocol(clk, reset, inbits, r_w, detect);

input clk;
input reset;
input [1:0] r_w;
input [2:0] inbits;
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
		if (r_w == 1'b0)
			case (state)
				2'b00:
				begin
					if (inbits == 3'b000) 
						state <= 2'b01;
					else if (inbits == 3'b010)
						state <= 2'b10;
					else
						state <= 2'b00;
				end
				2'b01:
				begin
					if (inbits == 3'b010)
						state <= 2'b01;
					else
						state <= 2'b00;
				end
				2'b10:
				begin
					if (inbits == 3'b101)
						state <= 2'b10;
					else if (inbits == 3'b110)
						state <= 2'b01;
					else
						state <= 2'b00;
				end
				2'b11:
				begin
					if (inbits == 3'b111)
						state <= 2'b11;
					else
						state <= 2'b00;
				end
			endcase
		else
			case (state)
				2'b00:
				begin
					if (inbits == 3'b000) 
						state <= 2'b10;
					else
						state <= 2'b00;
				end
				2'b01:
				begin
					if (inbits == 3'b010)
						state <= 2'b10;
					else
						state <= 2'b00;
				end
				2'b10:
				begin
					if (inbits == 3'b101)
						state <= 2'b11;
					else
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
