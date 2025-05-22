module datapath(
    input RESET,
    input clk,
    input [4:0] DebugSlctIn,
    input [1:0] PCSrc,
    input ResultSrc,
    input MemWrite,
    input [3:0] ALUControl,
    input ALUSrc,
    input [2:0] ImmSrc,
    input RegWrite,
    input [1:0] WD3Src,

    output [6:0] op,
    output [2:0] funct3,
    output funct7,
    output [31:0] DebugOut,
    output [31:0] PC,
    output [3:0] Flags //  NZCV
);



/////////////////////////
//////////WIRES//////////
/////////////////////////
wire [31:0] WD3;
wire [31:0] PCNext, PCPlus4, PCTarget, Instr, ImmExt;
wire [31:0] SrcA, SrcB, ALUResult;
wire [31:0] ReadData, WriteData, Result; 

assign op     = Instr[6:0];
assign funct3 = Instr[14:12];
assign funct7 = Instr[30];

/////////////////////////
//////// MODULES/////////
/////////////////////////
ALU #(32) alu_inst (     
  .control(ALUControl),
  .DATA_A(SrcA),        
  .DATA_B(SrcB),       
  .OUT(ALUResult),       
  .Flags(Flags) );
  
Register_file #(32) Register_file_inst(
   .clk(clk), 
   .write_enable(RegWrite), 
   .reset(RESET),
   .Source_select_0(Instr[19:15]), 
   .Source_select_1(Instr[24:20]), 
   .Debug_Source_select(DebugSlctIn), 
   .Destination_select(Instr[11:7]), 
   .DATA(WD3),              
   .out_0(SrcA), 
   .out_1(WriteData), 
   .Debug_out(DebugOut) 
);

Instruction_memory #(4,32)Instruction_memory_inst(
    .ADDR(PC), 
    .RD(Instr)  
);

Memory#(4,32) Memory_inst( 
    .clk(clk),
    .WE(MemWrite),
    .ADDR(ALUResult), 
    .funct3(funct3),
    .WD(WriteData), 
    .RD(ReadData)  
);

Extender Extender_inst(
    .Extended_data(ImmExt),
    .DATA(Instr[31:7]),     
    .select(ImmSrc)        
);

////////////////
////ADDDERS/////
////////////////
Adder #(32) Adder_PCPlus4 (.DATA_A(PC),.DATA_B(32'd4),.OUT(PCPlus4));
Adder #(32) Adder_PCTarget(.DATA_A(PC),.DATA_B(ImmExt),.OUT(PCTarget));

////////////
////MUX/////
////////////
// Select PC
Mux_4to1 #(32) Mux_PCNext(.select(PCSrc), .input_0(PCPlus4), .input_1(PCTarget), .input_2(Result), .output_value(PCNext));
// Select WD3
Mux_4to1 #(32) Mux_WD3(.select(WD3Src), .input_0(Result), .input_1(PCPlus4), .input_2(PCTarget), .output_value(WD3));
// Select ALU SrcB
Mux_2to1 #(32) Mux_SrcB(.select(ALUSrc), .input_0(WriteData), .input_1(ImmExt), .output_value(SrcB));
// Select Result
Mux_2to1 #(32) Mux_Result(.select(ResultSrc), .input_0(ALUResult), .input_1(ReadData), .output_value(Result));   

// For PC
Register_reset #(32)Register_reset_PC(.clk(clk), .reset(RESET),.DATA(PCNext),.OUT(PC)); 

endmodule
