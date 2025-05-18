module CONTROLLER (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] func7
);

wire Branch, Jump;

MainDecoder main_decoder_inst(
    .opcode(opcode),
    .Branch(Branch),
    .Jump(Jump),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite),
    .WD3Src(WD3Src),
    .ALUOp(ALUOp)
);