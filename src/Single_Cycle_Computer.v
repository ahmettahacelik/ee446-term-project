module Single_Cycle_Computer(
    input reset,               // External Reset
    input clk,                 // External Clock
    input [4:0] debug_reg_select,   // Select register to debug
    output [31:0] debug_reg_out,    // Debug register value output
    output [31:0] fetchPC           // Program Counter output
);
// Internal wires for datapath-controller connection
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire funct7;

    wire [1:0] PCSrc;
    wire ResultSrc;
    wire MemWrite;
    wire [2:0] ImmSrc;
    wire RegWrite;
    wire [1:0] WD3Src;
    wire [3:0] ALUControl;
    wire ALUSrc;

// Datapath instantiation
datapath my_datapath (
    .RESET(reset),
    .clk(clk),
    .DebugSlctIn(debug_reg_select),
    .PCSrc(PCSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite),
    .WD3Src(WD3Src),
    .op(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .DebugOut(debug_reg_out),
    .PC(fetchPC),
    .Flags(flags)
);

// Controller instantiation
controller my_controller (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .Flags(flags),
    .PCSrc(PCSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite),
    .WD3Src(WD3Src),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc)
);
endmodule



