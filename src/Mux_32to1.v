module Mux_32to1 #(parameter WIDTH = 32)(
    input  [4:0] select,
    input  [WIDTH-1:0] inputs [31:0],
    output [WIDTH-1:0] output_value
);

assign output_value = inputs[select];

endmodule
