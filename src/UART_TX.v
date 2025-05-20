module UART_TX #(
    parameter CLKS_PER_BIT = 10417  // CLKS_PER_BIT = 100MHz / 9600 baud rate = 10416.67 ~ 10417
)(
    input wire CLK100MHZ,
    input wire reset,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx,
    output reg tx_idle
);

localparam IDLE = 3'h0;
localparam START = 3'h1;
localparam DATA = 3'h2;
localparam STOP = 3'h3;
localparam DONE = 3'h4;

reg [2:0] state = IDLE;

reg [15:0] baud_counter = 0; // max(baud_counter) = 65535 ==> min(baud_rate) = ~1525 
reg [2:0] bit_index = 0;
reg [7:0] tx_shift_reg = 0;

always @(posedge CLK100MHZ) begin
    if (reset) begin
        state <= IDLE;
        tx <= 1'b1;  // UART idle state is high
        tx_idle <= 1'b1;
        baud_counter <= 0;
        bit_index <= 0;
        tx_shift_reg <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                tx <= 1'b1;
                if (tx_start == 1'b1) begin
                    tx_shift_reg <= tx_data;
                    state <= START;
                    baud_counter <= 0;
                end
            end

            START: begin
                tx <= 1'b0;  // Start bit
                if (baud_counter == (CLKS_PER_BIT - 1)) begin
                    baud_counter <= 0;
                    state <= DATA;
                    bit_index <= 0;
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end

            DATA: begin
                tx <= tx_shift_reg[bit_index];
                if (baud_counter == (CLKS_PER_BIT - 1)) begin
                    baud_counter <= 0;
                    if (bit_index == 3'h7) begin
                        state <= STOP;
                    end
                    else begin
                        bit_index <= bit_index + 1;
                    end
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end

            STOP: begin
                tx <= 1'b1;  // Stop bit
                if (baud_counter == (CLKS_PER_BIT - 1)) begin
                    baud_counter <= 0;
                    state <= DONE;
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end

            DONE: begin
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase

        tx_idle <= (state == IDLE) ? 1'b1 : 1'b0;
    end
end

endmodule
