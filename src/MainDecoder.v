module MainDecoder(
    input wire [6:0] opcode,
    output wire Branch,
    output wire [1:0] Jump,
    output wire ResultSrc,
    output wire MemWrite,
    output wire [2:0] ImmSrc,
    output wire RegWrite,
    output wire [1:0] WD3Src,
    output wire [1:0] ALUOp,
    output wire ALUSrc
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

// if(opcode == jalr) then jump = 10, ifelse(opcode == jal) then jump = 01, else jump = 0
assign Jump =   (opcode == opcode_I_JALR) ? 2'b10 :
                (opcode == opcode_J_JAL) ? 2'b01 : 2'b00;

// if(opcode == load) then resultsrc = 1, else resultsrc = 0
assign ResultSrc =  (opcode == opcode_I_LOAD) ? 1'b1 : 1'b0;

// if(opcode == s) then memwrite = 1, else memwrite = 0
assign MemWrite =   (opcode == opcode_S_STORE) ? 1'b1 : 1'b0;

assign ImmSrc = (opcode == opcode_I_IMM) ? 3'b000 :
                (opcode == opcode_I_LOAD) ? 3'b000 :
                (opcode == opcode_S_STORE) ? 3'b001 :
                (opcode == opcode_B_BRANCH) ? 3'b010 :
                (opcode == opcode_I_JALR) ? 3'b011 :
                (opcode == opcode_J_JAL) ? 3'b011 :
                (opcode == opcode_U_LUI) ? 3'b100 :
                (opcode == opcode_U_AUIPC) ? 3'b100 : 3'b000;

// if(opcode == s or b) then regwrite = 0, else regwrite = 1
assign RegWrite =   (opcode == opcode_S_STORE) ? 1'b0 :
                    (opcode == opcode_B_BRANCH) ? 1'b0 : 1'b1;

// if(opcode == jump) then wd3src = 01, ifelse(opcode == auipc) then w3dsrc = 10, else wd3src = 0 (same as jump)
assign WD3Src = (Jump == 1'b1) ? 2'b01 :
                (opcode == opcode_U_AUIPC) ? 2'b10 : 2'b00;

assign ALUOp =  (opcode == opcode_I_LOAD) ? 2'b00 :
                (opcode == opcode_S_STORE) ? 2'b00 :
                (opcode == opcode_R_REGISTER) ? 2'b10 :
                (opcode == opcode_B_BRANCH) ? 2'b01 :
                (opcode == opcode_I_IMM) ? 2'b10 :
                (opcode == opcode_I_JALR) ? 2'b00 :
                (opcode == opcode_U_AUIPC) ? 2'b00 :
                (opcode == opcode_U_LUI) ? 2'b11 : 2'b00;

assign ALUSrc = (opcode == opcode_I_LOAD) ? 1'b1 :
                (opcode == opcode_S_STORE) ? 1'b1 :
                (opcode == opcode_I_IMM) ? 1'b1 :
                (opcode == opcode_I_JALR) ? 1'b1 : 1'b0;
                
endmodule