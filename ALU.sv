//Top level module for the ALU
//`include "ALU_operations.v" // Include file for additional ALU operations like add,subtract,multiply,divide

module ALU(
    input signed  [63:0] A, // First operand
    input signed  [63:0] B, // Second operand
    input  Cin, // Carry-in
    input  [3:0] ALUCtrl, // ALU control signals, see ALU_Control.v
    output reg signed  [63:0] Result, // Result of the operation
    output reg Zero, // Flag to indicate if the result is zero
    output reg Overflow // Flag to indicate if the result overflows
);

    // Intermediate signals to hold results from the CLA and Subtractor
    wire signed [63:0] Add_result;
    wire signed [63:0] Sub_result;
    wire Cout_add, Cout_sub, Overflow_add, Overflow_sub;

    // Flag signals indicating which operation is currently selected
    wire Add_selected, Sub_selected;

    // Instantiate the CLA_64bit module
    CLA_64bit cla_inst(
        .A(A),
        .B(B),
        .Cin(Cin), // Assuming add with no carry-in
        .Result(Add_result),
        .Cout(Cout_add),
        .Overflow(Overflow_add)
    );

    // Instantiate the Subtractor_64bit module
    Subtractor_64bit Sub_inst(
        .A(A),
        .B(B),
        .Cin(1'b0), // Assuming subtract with borrow-in
        .Result(Sub_result),
        .Cout(Cout_sub),
        .Overflow(Overflow_sub)
    );

    assign Add_selected = (ALUCtrl == 4'b0010); // ADD operation
    assign Sub_selected = (ALUCtrl == 4'b0110); // SUB operation
    
    always @(*) begin
        case(ALUCtrl)
            4'b0010: begin // ADD, see CLA_64bit.sv
                Result = Add_result;
                Overflow = Overflow_add; // Assign overflow from the adder
            end
            4'b0110: begin // SUB, see Subtractor_64bit.sv
                Result = Sub_result;
                Overflow = Overflow_sub; // Assign overflow from the subtractor
            end
            4'b0011: Result = A * B; // MUL
            4'b0001: Result = A / B; // DIV (ensure B is not zero)
            4'b0111: Result = (A < B) ? 1 : 0; // SLT (Set on Less Than)
            4'b0000: Result = A & B; // AND
            default: begin
                Result = 64'b0; // Default case
                Overflow = 1'b0; // No Overflow by default 
            end
        endcase

        // Set Zero flag
        Zero = (Result == 64'b0) ? 1'b1 : 1'b0;
    end

endmodule
