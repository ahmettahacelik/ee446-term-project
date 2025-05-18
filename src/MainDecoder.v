module MainDecoder(
    input wire [6:0] opcode,
    output wire Branch,
    output wire Jump,
    output wire ResultSrc,
    output wire MemWrite,
    output wire [1:0] ImmSrc,
    output wire RegWrite,
    output wire WD3Src,
    output wire [1:0] ALUOp
);


// BEGIN Instruction OPCodes
localparam opcode_R_REGISTER = 7'b0110011;

localparam opcode_I_IMM = 7'b0010011;
localparam opcode_I_LOAD = 7'b00000011;
localparam opcode_I_JALR = 7'b1100111;

localparam opcode_S_STORE = 7'b0100011;

localparam opcode_B_BRANCH = 7'b1100011;

localparam opcode_U_LUI = 7'b0110111;
localparam opcode_U_AUIPC = 7'b0010111;

localparam opcode_J_JAL = 7'b1101111;
// END Instruction OPCodes


// if(opcode == branch) then branch = 1, else branch = 0
assign Branch = (opcode == opcode_B_BRANCH) ? 1'b1 : 1'b0;

// if(opcode == jump) then jump = 1, else jump = 0
assign Jump =   (opcode == opcode_I_JALR) ? 1'b1 :
                (opcode == opcode_J_JAL) ? 1'b1 : 1'b0;

// if(opcode == load) then resultsrc = 1, else resultsrc = 0
assign ResultSrc =  (opcode == opcode_I_LOAD) ? 1'b1 : 1'b0;

// if(opcode == s) then memwrite = 1, else memwrite = 0
assign MemWrite =   (opcode == opcode_S_STORE) ? 1'b1 : 1'b0;

// TODO
assign ImmSrc = 2'b00;

// if(opcode == s or b) then regwrite = 0, else regwrite = 1
assign RegWrite =   (opcode == opcode_S_STORE) ? 1'b0 :
                    (opcode == opcode_B_BRANCH) ? 1'b0 : 1'b1;

// if(opcode == jump) then wd3src = 1, else wd3src = 0 (same as jump)
assign WD3Src = Jump;

// TODO
assign ALUOp = 2'b00;