module UART_RX #(
    parameter CLKS_PER_BIT = 10417  // CLKS_PER_BIT = 100MHz / 9600 baud rate = 10416.67 ~ 10417
)(
    input wire CLK100MHZ,
    input wire reset,
    input wire rx,
    output reg [7:0] rx_data,
    output reg rx_done
);

localparam IDLE = 3'h0;
localparam START = 3'h1;
localparam DATA = 3'h2;
localparam STOP = 3'h3;
localparam DONE = 3'h4;

reg [2:0] state = IDLE;

reg [15:0] baud_counter = 0; // max(baud_counter) = 65535 ==> min(baud_rate) = ~1525 
reg [2:0] bit_index = 0;

always @(posedge CLK100MHZ) begin
    if(reset == 1'b1) begin
        state <= IDLE;
        baud_counter <= 0;
        bit_index <= 0;
        rx_data <= 0;
        rx_done <= 0;
    end
    else begin
        rx_done <= 0;

        case(state)
            IDLE: begin
                state <= (rx == 1'b0) ? START : IDLE;
                baud_counter <= 0;
            end

            START: begin
                if(baud_counter == (CLKS_PER_BIT >> 1)) begin
                    if(rx == 1'b0) begin //still low: valid start
                        baud_counter <= 0;
                        bit_index <= 0;
                        state <= DATA;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end

            DATA: begin
                if(baud_counter == (CLKS_PER_BIT - 1)) begin
                    baud_counter <= 0;
                    rx_data[bit_index] <= rx;
                    if(bit_index == 3'h7) begin
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
                if(baud_counter == (CLKS_PER_BIT - 1)) begin
                    state <= (rx == 1'b1) ? DONE : IDLE; // valid stop bit
                    baud_counter <= 0;
                end
                else begin
                    baud_counter <= baud_counter + 1;
                end
            end

            DONE: begin
                rx_done <= 1'b1;
                state <= IDLE;
            end

            default: state <= IDLE;

        endcase
    end

end

endmodule