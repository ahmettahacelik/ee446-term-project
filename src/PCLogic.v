module PCLogic (
    input wire Branch,
    input wire [1:0] Jump,
    input wire [2:0] funct3,
    input wire [3:0] Flags,       // N, Z, C, V
    output wire [1:0] PCSrc
);

wire N, Z, C, V;
assign N = Flags[3];
assign Z = Flags[2];
assign C = Flags[1];
assign V = Flags[0];

localparam branchBEQ = 3'b000;
localparam branchBNE = 3'b001;
localparam branchBLT = 3'b100;
localparam branchBLTU = 3'b110;
localparam branchBGE = 3'b101;
localparam branchBGEU = 3'b111;

reg CondEx;

always @(*) begin
    case (funct3)
        branchBEQ: CondEx = Z;
        branchBNE: CondEx = ~Z;
        branchBLT: CondEx = N ^ V;
        branchBLTU: CondEx = ~C;
        branchBGE: CondEx = ~(N ^ V);
        branchBGEU: CondEx = C;
        default: CondEx = 1'b0;
    endcase
end

assign PCSrc =  (Jump == 2'b10) ? 2'b10 :
                (Jump == 2'b01) ? 2'b01 :
                (Branch & CondEx == 1'b1) ? 2'b01 : 2'b00;
             
endmodule