module FIFO #(parameter DEPTH = 16, parameter LOG_DEPTH = 4, parameter WIDTH=8)(
    input wire clk_write,
    input wire clk_read,
    input wire reset,
    input wire write_enable,
    input wire [WIDTH-1:0] write_data,
    input wire read_enable,
    output reg [WIDTH-1:0] read_data,
    output reg valid
);

reg [(WIDTH-1):0] mem [0:(DEPTH-1)];

reg [(LOG_DEPTH-1):0] write_pointer = 0;
reg [(LOG_DEPTH-1):0] read_pointer = 0;

reg [LOG_DEPTH:0] write_count = 0;
reg [LOG_DEPTH:0] read_count = 0;

wire full, empty;
assign full = ((write_count - read_count) == DEPTH);
assign empty = (write_count == read_count);

// write logic
always @(posedge clk_write) begin
    if(reset == 1'b1) begin
        write_pointer <= 0;
        write_count <= 0;
    end
    else if((write_enable == 1'b1) && !full) begin
        mem[write_pointer] <= write_data;
        write_pointer <= write_pointer + 1;
        write_count <= write_count + 1;
    end
end

// read logic
always @(negedge clk_read) begin
    if(reset == 1'b1) begin
        read_pointer <= 0;
        read_count <= 0;
        read_data <= 0;
        valid <= 1'b0;
    end
    else if((read_enable == 1'b1) && !empty) begin
        read_data <= mem[read_pointer];
        read_pointer <= read_pointer + 1;
        read_count <= read_count + 1;
        valid <= 1'b1;
    end
    else begin
        valid <= 1'b0;
    end
end

endmodule