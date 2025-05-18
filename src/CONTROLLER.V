module controller (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire funct7,
    input wire [3:0] Flags,
    output wire [1:0] PCSrc,
    output wire ResultSrc,
    output wire MemWrite,
    output wire [2:0] ImmSrc,
    output wire RegWrite,
    output wire [1:0] WD3Src,
    output wire [3:0] ALUControl,
    output wire ALUSrc
);

wire Branch;
wire [1:0] Jump, ALUOp;

MainDecoder main_decoder_inst(
    .opcode(opcode),
    .Branch(Branch),
    .Jump(Jump),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite),
    .WD3Src(WD3Src),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc)
);

PCLogic pclogic_inst(
    .Branch(Branch),
    .Jump(Jump),
    .funct3(funct3),
    .Flags(Flags),
    .PCSrc(PCSrc)
);

ALUDecoder aludecoder_inst(
    .ALUOp(ALUOp),
    .op5(opcode[5]),
    .funct3(funct3),
    .funct7(funct7),
    .ALUControl(ALUControl)
);

endmodule