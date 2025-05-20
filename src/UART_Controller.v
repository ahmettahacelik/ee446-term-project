module UART_Controller (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [31:0] ALUResult, // ADDR
    output reg uart_rx,
    output reg uart_tx
);

localparam opcode_I_LOAD = 7'b00000011;
localparam opcode_S_STORE = 7'b0100011;

always @(*) begin
    uart_tx = 1'b0;
    uart_rx = 1'b0;
    if((opcode == opcode_I_LOAD) && (funct3 == 3'b010) && (ALUResult == 32'h00000404)) begin
        uart_rx = 1'b1;
    end
    else if((opcode == opcode_S_STORE) && (funct3 == 3'b000) && (ALUResult == 32'h00000400)) begin
        uart_tx = 1'b1;
    end
end

endmodule