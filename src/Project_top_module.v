

module Project_top_module(
    //////////// GCLK //////////
    input wire                  CLK100MHZ,
	//////////// BTN //////////
	input wire		     		BTNU, 
	                      BTNL, BTNC, BTNR,
	                            BTND,
	//////////// SW //////////
	input wire	     [15:0]		SW,

    /////////// UART /////////
    input wire UART_TXD_IN,
    output wire UART_RXD_OUT,

	//////////// LED //////////
	output wire		 [15:0]		LED,
    //////////// 7 SEG //////////
    output wire [7:0] AN,
    output wire CA, CB, CC, CD, CE, CF, CG, DP
);

wire [31:0] reg_out, PC;
wire [4:0] buttons;

assign LED[3:0] = SW[3:0];
assign LED[15] = buttons[4]; 
assign LED[14] = buttons[0];
MSSD mssd_0(
        .clk        (CLK100MHZ                      ),
        .value      ({PC[7:0], reg_out[23:0]}       ),
        .dpValue    (8'b01000000                    ),
        .display    ({CG, CF, CE, CD, CC, CB, CA}   ),
        .DP         (DP                             ),
        .AN         (AN                             )
    );

debouncer debouncer_0(
        .clk        (CLK100MHZ                      ),
        .buttons    ({BTNU, BTNL, BTNC, BTNR, BTND} ),
        .out        (buttons                        )
    );

Single_Cycle_Computer my_computer(
        .CLK100MHZ          (CLK100MHZ              ),
        .clk                (buttons[4]             ),
        .reset              (buttons[0]             ),
        .debug_reg_select   (SW[4:0]                ),
        .debug_reg_out      (reg_out                ),
        .fetchPC            (PC                     ),
        .UART_RXD_OUT       (UART_RXD_OUT           ),
        .UART_TXD_IN        (UART_TXD_IN            )
);

endmodule
