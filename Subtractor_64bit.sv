module Subtractor_64bit(
    input signed [63:0] A,
    input signed [63:0] B,
    output signed [63:0] Result,
    output Overflow
);
    wire signed [63:0] Twos_complement_B;
    wire Carry_out; // Carry out of the addition

    // Calculate two's complement of B
    assign Twos_complement_B = ~B + 1;

    // Use CLA_64bit for the operation in order to compute the addition of two 
    CLA_64bit CLA_instance (
        .A(A),
        .B(Twos_complement_B),
        .Cin(1'b0),  // As we already added 1 in the two's complement
        .Sum(Result),
        .Cout(Carry_out)
    );

    // Overflow logic
    assign Overflow = (A[63] != B[63]) && (Result[63] != A[63]);

endmodule
