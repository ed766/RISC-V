
//This is the module that controls ALU control signals
module ALU_Control(ALUOp, Func3, Func7, ALUCtrl);

	input [6:0] ALUOp;
	input [2:0] Func3;
	input [6:0] Func7;
	output reg [3:0] ALUCtrl;
	//Define OP codes from reference card
	localparam ADD_OP = 7'b0000000;
	localparam AND_OP = 7'b0000000;
	localparam DIV_OP = 7'b0000001;
	localparam MUL_OP = 7'b0000001;
	localparam SLT_OP = 7'b0000000;
	localparam SUB_OP = 7'b0100000;
	//Define ALU Control codes, not from reference card, done by myself
	localparam ALU_ADD = 4'b0010;
	localparam ALU_AND = 4'b0000;
	localparam ALU_DIV = 4'b0001;
	localparam ALU_MUL = 4'b0011;
	localparam ALU_SUB = 4'b0110;
	localparam ALU_SLT = 4'b0111;
	always@(*) begin
	
		case(ALUOp)

		//R-type operations

			7'b0110011: begin

				case(Func3)

					3'b000: ALUCtrl = (Func7 == ADD_OP) ? ALU_ADD : 
							          (Func7 == MUL_OP) ? ALU_MUL : 
							          (Func7 == SUB_OP) ? ALU_SUB : 4'b1111;
					3'b010: ALUCtrl = (Func7 == SLT_OP) ? ALU_SLT : 4'b1111;
					3'b100: ALUCtrl = (Func7 == DIV_OP) ? ALU_DIV : 4'b1111;
					3'b111: ALUCtrl = (Func7 == AND_OP) ? ALU_AND : 4'b1111;
				endcase
			end
		endcase
	end
endmodule
