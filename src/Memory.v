module Memory#(
    parameter BYTE_SIZE = 4,       // Usually 4 bytes = 32 bits
    parameter ADDR_WIDTH = 32
)(
    input clk,
    input WE,
    input [ADDR_WIDTH-1:0] ADDR,
    input [31:0] WD,
    input [2:0] funct3,            // funct3[2] for sign/zero extension
    output reg [31:0] RD
);

reg [7:0] mem [255:0];  // byte-addressable memory
integer i;
initial begin
    for (i = 0; i < 4096; i = i + 1) begin
        mem[i] = 8'b0;
    end
end
integer k;

always @(posedge clk) begin
    if (WE) begin
        case (funct3)
            3'b000: mem[ADDR]     <= WD[7:0];               // SB
            3'b001: begin                                   // SH
                mem[ADDR]     <= WD[7:0];
                mem[ADDR + 1] <= WD[15:8];
            end
            3'b010: begin                                   // SW
                for (k = 0; k < 4; k = k + 1)
                    mem[ADDR + k] <= WD[8*k +: 8];
            end
            default: ; // No write
        endcase
    end
end

always @(*) begin
    case (funct3)
        3'b000: RD = {{24{mem[ADDR][7]}}, mem[ADDR]};                  // LB
        3'b001: RD = {{16{mem[ADDR + 1][7]}}, mem[ADDR + 1], mem[ADDR]}; // LH
        3'b010: RD = {mem[ADDR + 3], mem[ADDR + 2], mem[ADDR + 1], mem[ADDR]}; // LW
        3'b100: RD = {24'b0, mem[ADDR]};                               // LBU
        3'b101: RD = {16'b0, mem[ADDR + 1], mem[ADDR]};                // LHU
        default: RD = 32'b0;
    endcase
end

endmodule
