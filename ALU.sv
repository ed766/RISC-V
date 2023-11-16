//Top level module for the ALU
//`include "ALU_operations.v" // Include file for additional ALU operations like add,subtract,multiply,divide

module ALU(
    input wire [63:0] A, // First operand
    input wire [63:0] B, // Second operand
    input wire [3:0] ALUCtrl, // ALU control signals, see ALU_Control.v
    output reg [63:0] Result, // Result of the operation
    output reg Zero // Flag to indicate if the result is zero
);

    always @(*) begin
        case(ALUCtrl)
            4'b0010: Result = A + B; // ADD, see CLA_64bit.sv
            4'b0110: Result = A - B; // SUB, see Subtractor_64bit.sv
            4'b0011: Result = A * B; // MUL
            4'b0001: Result = A / B; // DIV (ensure B is not zero)
            4'b0111: Result = (A < B) ? 1 : 0; // SLT (Set on Less Than)
            4'b0000: Result = A & B; // AND
            default: Result = 64'b0; // Default case
        endcase

        // Set Zero flag
        Zero = (Result == 64'b0) ? 1'b1 : 1'b0;
    end

endmodule
