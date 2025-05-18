module CONTROLLER (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire func7_5,
    input wire [3:0] Flags
    output wire [1:0] PCSrc,
    output wire ResultSrc,
    output wire MemWrite,
    output wire [1:0] ImmSrc,
    output wire RegWrite,
    output wire WD3Src,
    output wire [1:0] ALUOp
);

wire Branch;
wire [1:0] Jump;

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

PCLogic pclogic_inst(
    .Branch(Branch),
    .Jump(Jump),
    .func3(func3),
    .Flags(Flags),
    .PCSrc(PCSrc)
);