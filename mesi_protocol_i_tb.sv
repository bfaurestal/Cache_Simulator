`timescale 10ns/100ps

module mesi_protocol_tb;

reg [4:0] dummy_reg;
reg clk_tb;
reg reset_tb;
reg [1:0] inbits_tb;
reg r_w;
wire detect;

reg [1:0] state;

integer count = 0; // counter variable

parameter MAX_TEST_CASES = 5; // maximum number of test cases

initial begin
    clk_tb = 0;
    reset_tb = 0;
    inbits_tb = 0;
    state = 2'b00;
end

initial begin
    reset_tb = 1'b1;
    #15 reset_tb = 1'b0;
end

always begin
    #10 clk_tb = !clk_tb;
end

always begin
    #1;
    if (count < MAX_TEST_CASES) begin
        r_w = count % 2; // alternate between read and write
        if (r_w) begin
            // write operation
            inbits_tb = 2'b01;
            $display("Operation: Write");
        end
        else begin
            // read operation
            inbits_tb = 2'b11;
            $display("Operation: Read");
        end
        
        count = count + 1; // increment counter after each test case
        if (count == MAX_TEST_CASES) begin
            $finish; // end simulation
        end
    end
end

always @(posedge clk_tb) begin
    if (reset_tb) begin
        state <= 2'b00;
    end
    else begin
        case (state)
            2'b00: begin
                if (inbits_tb[2:0] == 3'b001) begin
                    state <= 2'b01;
                    $display("State: I -> S");
                end
                else begin
                    state <= 2'b10;
                    $display("State: I -> E");
                end
            end
            2'b01: begin
                if (inbits_tb[2:0] == 3'b001) begin
                    state <= 2'b11;
                    $display("State: S -> M");
                end
                else begin
                    state <= 2'b10;
                    $display("State: S -> E");
                end
            end
            2'b10: begin
                if (inbits_tb[2:0] == 3'b001) begin
                    state <= 2'b01;
                    $display("State: E -> S");
                end
                else begin
                    state <= 2'b11;
                    $display("State: E -> M");
                end
            end
            2'b11: begin
                if (inbits_tb[2:0] != 3'b001) begin
                    state <= 2'b01;
                    $display("State: M -> S");
                end
                else begin
                    state <= 2'b10;
                    $display("State: M -> E");
                end
            end
            default: begin
                state <= 2'b00;
            end
        endcase
    end
end

mesi_protocol mesi_protocol_inst(.clk(clk_tb), .inbits(inbits_tb), .detect(detect), .reset(reset_tb), .r_w(r_w));

endmodule
