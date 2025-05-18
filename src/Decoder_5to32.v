module Decoder_5to32 (
    input  [4:0] IN,
    output [31:0] OUT
);

assign OUT = 32'b1 << IN;

endmodule
