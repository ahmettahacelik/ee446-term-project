module Register_file #(parameter WIDTH = 32)(
    input clk, write_enable, reset,
    input [4:0] Source_select_0, Source_select_1, Debug_Source_select, Destination_select,
    input [WIDTH-1:0] DATA,
    output [WIDTH-1:0] out_0, out_1, Debug_out
);

wire [WIDTH-1:0] Reg_Out [31:0];
wire [31:0] Reg_enable;

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin : registers
        if (i == 0) begin
            // Register x0 is always zero
            assign Reg_Out[i] = {WIDTH{1'b0}};
        end else begin
            Register_rsten #(WIDTH) Reg (
                .clk(clk),
                .reset(reset),
                .we(Reg_enable[i] & write_enable),
                .DATA(DATA),
                .OUT(Reg_Out[i])
            );
        end
    end
endgenerate

// Decoder that enables only the selected register, but never enables x0
Decoder_5to32 dec (
    .IN(Destination_select),
    .OUT(Reg_enable)
);

// Multiplexers to read from register file
Mux_32to1 #(WIDTH) mux_0 (.select(Source_select_0), .inputs(Reg_Out), .output_value(out_0));
Mux_32to1 #(WIDTH) mux_1 (.select(Source_select_1), .inputs(Reg_Out), .output_value(out_1));
Mux_32to1 #(WIDTH) mux_2 (.select(Debug_Source_select), .inputs(Reg_Out), .output_value(Debug_out));

endmodule
