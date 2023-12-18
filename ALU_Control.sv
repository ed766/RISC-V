
//This is the module that controls ALU control signals
module ALU_Control(ALUOp, Func3, Func7, ALUCtrl);
	input [6:0] ALUOp; //Op code from reference card, determines which operation type to perform
	input [2:0] Func3; //Function3 code from reference card
	input [6:0] Func7; //Function7 code from reference card
	output reg [3:0] ALUCtrl;
	//Define ALU Control codes, not from reference card, done by myself
	localparam ALU_ADD = 4'b0010;
	localparam ALU_AND = 4'b0000;
	localparam ALU_DIV = 4'b0001;
	localparam ALU_MUL = 4'b0011;
	localparam ALU_OR = 4'b1000;
	localparam ALU_SUB = 4'b0110;
	localparam ALU_SLT = 4'b0111;
	localparam ALU_XOR = 4'b1110;
	always@(*) begin
		case(ALUOp)

		//R-type operations

			R_Type: begin

				case(Func3)

					ADDMULSUB_Func3: ALUCtrl = (Func7 == ADDANDSLT_Func7) ? ALU_ADD : 
							          (Func7 == MULDIV_Func7) ? ALU_MUL : 
							          (Func7 == SUB_Func7) ? ALU_SUB : 4'b1111;
					SLT_Func3: ALUCtrl = (Func7 == SLT_Func7) ? ALU_SLT : 4'b1111;
					DIV_Func3: ALUCtrl = (Func7 == MULDIV_Func7) ? ALU_DIV : 4'b1111;
					AND_Func3: ALUCtrl = (Func7 == AND_Func7) ? ALU_AND : 4'b1111;
				endcase
			end
		endcase
	end
endmodule
