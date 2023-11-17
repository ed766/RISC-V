module Subtractor_64bit(
    input signed [63:0] A,
    input signed [63:0] B,
    input Cin,
    output signed [63:0] Result,
    output Overflow,
    output Cout
);
    wire signed [63:0] Twos_complement_B;

    // Calculate two's complement of B
    assign Twos_complement_B = ~B + 1;

    // Use CLA_64bit for the operation in order to compute the addition of two 
    CLA_64bit CLA_instance (
        .A(A),
        .B(Twos_complement_B),
        .Cin(1'b0),  // As we already added 1 in the two's complement
        .Result(Result),
        .Cout(Cout),
        .Overflow(Overflow)
    );

    // Overflow logic
    assign Overflow = (A[63] != B[63]) && (Result[63] != A[63]);

endmodule
