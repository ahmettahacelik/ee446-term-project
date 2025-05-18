module ALUDecoder(
    input wire [1:0] ALUOp,
    input wire op5,
    input wire [2:0] funct3,
    input wire funct7_5,
    output reg [3:0] ALUControl
);

localparam ALU_ADD = 4'b0000;
localparam ALU_SUB = 4'b0001;
localparam ALU_AND = 4'b0010;
localparam ALU_OR = 4'b0011;
localparam ALU_XOR = 4'b0100;
localparam ALU_SLT = 4'b0101;
localparam ALU_SLL = 4'b0110;
localparam ALU_SRL = 4'b0111;
localparam ALU_SRA = 4'b1000;
localparam ALU_MOV = 4'b1001;
localparam ALU_SLTU = 4'b1010;

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = ALU_ADD; // LOAD, STORE, JALR, AUIPC
        2'b01: ALUControl = ALU_SUB; // BRANCH
        2'b10: begin // R TYPE INSTRUCTIONS
            case (funct3)
                3'b000: ALUControl = ({op5, funct7_5} == 2'b11) ? ALU_SUB : ALU_ADD;
                3'b001: ALUControl = ALU_SLL;
                3'b010: ALUControl = ALU_SLT;
                3'b011: ALUControl = ALU_SLTU;
                3'b100: ALUControl = ALU_XOR;
                3'b101: ALUControl = (funct7_5 == 1'b1) ? ALU_SRA : ALU_SRL;
                3'b110: ALUControl = ALU_OR;
                3'b111: ALUControl = ALU_AND;
                default: ALUControl = ALU_ADD;
            endcase
        end
        2'b11: ALUControl = ALU_MOV; // LUI
    endcase
end
endmodule