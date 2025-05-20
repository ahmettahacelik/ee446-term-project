module UART (
    input wire CLK100MHZ,
    input wire clk,
    input wire reset,
    input wire rx,
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [31:0] ALUResult,
    input wire [31:0] ReadData,
    input wire [31:0] WriteData,
    output wire [31:0] ReadData_RX,
    output wire tx
);

wire uart_rx, uart_tx;

UART_Controller uart_controller_inst(
    .opcode(opcode),
    .funct3(funct3),
    .ALUResult(ALUResult),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx)
);

wire [7:0] rx_data;
wire rx_done;

UART_RX uart_rx_inst(
    .CLK100MHZ(CLK100MHZ),
    .reset(reset),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

wire tx_idle;

// for only one transmission per instruction ///////////////////
reg uart_tx_prev;
wire tx_start;

always @(posedge CLK100MHZ) begin
    uart_tx_prev <= uart_tx;
end

assign tx_start = (uart_tx == 1'b1) && (uart_tx_prev == 1'b0);
////////////////////////////////////////////////////////////////

UART_TX uart_tx_inst(
    .CLK100MHZ(CLK100MHZ),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(WriteData[7:0]),
    .tx(tx),
    .tx_idle(tx_idle)
);

wire rx_fifo_valid;
wire [7:0] rx_fifo_read;

FIFO uart_rx_fifo(
    .clk(clk),
    .reset(reset),
    .write_enable(rx_done),
    .write_data(rx_data),
    .read_enable(uart_rx),
    .read_data(rx_fifo_read),
    .valid(rx_fifo_valid)
);

wire [31:0] rx_fifo_out;

// if rx_fifo_read is invalid then 0xFFFFFFFF should be returned
Mux_2to1 #(32) uart_fifo_mux(.select(rx_fifo_valid), .input_0(32'hFFFFFFFF), .input_1({24'h0, rx_fifo_read}), .output_value(rx_fifo_out));

// if current instruction is uart_rx then fifo_out is selected instead of memory output
Mux_2to1 #(32) uart_receive_mux(.select(uart_rx), .input_0(ReadData), .input_1(rx_fifo_out), .output_value(ReadData_RX));


endmodule