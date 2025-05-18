module Extender (
    output reg [31:0] Extended_data,
    input      [24:0] DATA,       
    input      [2:0]  select      // ImmSrc: 000=I, 001=S, 010=B, 011=J, 100=U
);

always @(*) begin
    case (select)
        // I-type: {20{instr[31]}}, instr[31:20]
        3'b000: Extended_data = {{20{DATA[24]}}, DATA[24:13]};

        // S-type: {20{instr[31]}}, instr[31:25], instr[11:7]
        3'b001: Extended_data = {{20{DATA[24]}}, DATA[24:18], DATA[4:0]};

        // B-type: {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0
        3'b010: Extended_data = {{20{DATA[24]}}, DATA[0], DATA[23:18], DATA[4:1], 1'b0};

        // J-type: {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0
        3'b011: Extended_data = {{12{DATA[24]}}, DATA[12:5], DATA[13], DATA[23:14], 1'b0};

        // U-type: instr[31:12] << 12 = {instr[31:12], 12'b0}
        3'b100: Extended_data = {DATA[24:5], 12'b0};

        default: Extended_data = 32'b0;
    endcase
end

endmodule
