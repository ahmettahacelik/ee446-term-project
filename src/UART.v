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

/// UART CONTROLLER
wire uart_rx, uart_tx;

UART_Controller uart_controller_inst(
    .opcode(opcode),
    .funct3(funct3),
    .ALUResult(ALUResult),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx)
);

/// UART RX
wire [7:0] rx_data;
wire rx_done;

UART_RX uart_rx_inst(
    .CLK100MHZ(CLK100MHZ),
    .reset(reset),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

reg rx_done_reg;
reg [7:0] rx_data_reg;

always @(posedge CLK100MHZ) begin
    rx_done_reg <= rx_done;
    rx_data_reg <= rx_data;
end

wire rx_fifo_valid;
wire [7:0] rx_fifo_read;

FIFO uart_rx_fifo(
    .clk_write(CLK100MHZ),
    .clk_read(clk),
    .reset(reset),
    .write_enable(rx_done_reg),
    .write_data(rx_data_reg),
    .read_enable(uart_rx),
    .read_data(rx_fifo_read),
    .valid(rx_fifo_valid)
);

wire [31:0] rx_fifo_out;

// if rx_fifo_read is invalid then 0xFFFFFFFF should be returned
Mux_2to1 #(32) uart_fifo_mux(.select(rx_fifo_valid), .input_0(32'hFFFFFFFF), .input_1({24'h0, rx_fifo_read}), .output_value(rx_fifo_out));

// if current instruction is uart_rx then fifo_out is selected instead of memory output
Mux_2to1 #(32) uart_receive_mux(.select(uart_rx), .input_0(ReadData), .input_1(rx_fifo_out), .output_value(ReadData_RX));

/// UART TX
wire tx_idle;
wire [7:0] tx_fifo_read;
wire tx_fifo_valid;

FIFO uart_tx_fifo(
    .clk_write(clk),
    .clk_read(CLK100MHZ),
    .reset(reset),
    .write_enable(uart_tx),
    .write_data(WriteData[7:0]),
    .read_enable(tx_idle),
    .read_data(tx_fifo_read),
    .valid(tx_fifo_valid)
);

UART_TX uart_tx_inst(
    .CLK100MHZ(CLK100MHZ),
    .reset(reset),
    .tx_start(tx_fifo_valid),
    .tx_data(tx_fifo_read),   
    .tx(tx),
    .tx_idle(tx_idle)
);

endmodule