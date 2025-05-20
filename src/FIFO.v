module FIFO #(parameter DEPTH = 16, parameter LOG_DEPTH = 4, parameter WIDTH=8)(
    input wire clk,
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

reg [LOG_DEPTH:0] count = 0;

// write logic
always @(posedge clk) begin
    if(reset == 1'b1) begin
        write_pointer <= 0;
    end
    else if(write_enable == 1'b1) begin
        if(count == DEPTH) begin // fifo is full

        end
        else begin
            mem[write_pointer] <= write_data;
            write_pointer <= write_pointer + 1;
        end
    end
end

// read logic
always @(posedge clk) begin
    valid = 1'b0;
    if(reset == 1'b1) begin
        read_pointer <= 0;
    end
    else if(read_enable == 1'b1) begin
        if(count == 0) begin // fifo is empty

        end
        else begin
            read_data <= mem[read_pointer];
            read_pointer <= read_pointer + 1;
            valid <= 1'b1;
        end
    end
end

// count logic
always @(posedge clk) begin
    if(reset == 1'b1) begin
        count <= 0;
    end
    else if((write_enable == 1'b1) && (count < DEPTH)) begin
        count <= count + 1;
    end
    else if((read_enable == 1'b1) && (count != 0)) begin
        count <= count - 1;
    end
end

endmodule