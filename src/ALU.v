module ALU #(parameter WIDTH=32)(
	  input [3:0] control,
	  input CI,
	  input [WIDTH-1:0] DATA_A,
	  input [WIDTH-1:0] DATA_B,
      output reg [WIDTH-1:0] OUT,
	  output [3:0] Flags  //  NZCV
    );
// for branch instructions alucontrol= sub 
// for lw sw alucontrol=add
// for lui alucontrol=move  
// for auipc,jal alucontrol xxxx    
localparam ADD=4'b0000,
		  SUB=4'b0001,
		  AND=4'b0010,
		  ORR=4'b0011,
          EXOR=4'b0100,
          SLT=4'b0101, 		  
		  SLL=4'b0110,
          SRL=4'b0111,
          SRA=4'b1000,
          MOVE=4'b1001,
          SLTU=4'b1010 ;
reg CO,OVF;
// Assign the zero and negative flasg here since it is very simple
wire N = OUT[WIDTH-1];
wire Z = ~(|OUT);
assign Flags = {N, Z, CO, OVF};  // NZCV	 
always@(*) begin
	case(control)
	    ADD:begin
			{CO,OUT} = DATA_A + DATA_B + CI;
			OVF = (DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		SUB:begin
			{CO,OUT} =  DATA_A +  $unsigned(~DATA_B) +  1'b1;
			OVF = (DATA_A[WIDTH-1] & ~DATA_B[WIDTH-1] & ~OUT[WIDTH-1]) | (~DATA_A[WIDTH-1] & DATA_B[WIDTH-1] & OUT[WIDTH-1]);
		end
		AND:begin
			OUT = DATA_A & DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		ORR:begin
			OUT = DATA_A | DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		EXOR:begin
			OUT = DATA_A ^ DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		SLT: begin
			// Signed less than: if A < B then 1 else 0
			OUT = ($signed(DATA_A) < $signed(DATA_B)) ? 32'd1 : 32'd0;
			CO = 1'b0;
			OVF = 1'b0;
		end
		SLTU: begin
			// Unsigned less than: if A < B then 1 else 0
			OUT = (DATA_A < DATA_B) ? 32'd1 : 32'd0;
			CO = 1'b0;
			OVF = 1'b0;
		end
		SLL: begin
			// Logical left shift by lower 5 bits of DATA_B
			OUT = DATA_A << DATA_B[4:0];
			CO = 1'b0;
			OVF = 1'b0;
		end
		SRL: begin
			// Logical right shift by lower 5 bits of DATA_B
			OUT = DATA_A >> DATA_B[4:0];
			CO = 1'b0;
			OVF = 1'b0;
		end
		SRA: begin
			// Arithmetic right shift by lower 5 bits of DATA_B
			OUT = $signed(DATA_A) >>> DATA_B[4:0];
			CO = 1'b0;
			OVF = 1'b0;
		end
		MOVE:begin
			OUT = DATA_B;
			CO = 1'b0;
			OVF = 1'b0;
		end
		default:begin
		OUT = {WIDTH{1'b0}};
		CO = 1'b0;
		OVF = 1'b0;
		end
	endcase
end
	 
endmodule	 