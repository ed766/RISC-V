//This is the full 64 bit CLA adder that takes in two 64 bit numbers and outputs the Sum and Carry out, it is made up of 16 4 bit CLA adders and is used by the ALU
`include "CLA_4bit.sv"
module CLA_64bit(
    input signed [63:0] A,
    input signed [63:0] B,
    input Cin,
    output signed [63:0] Sum,
    output Cout,
    output Overflow
);
    wire [15:0] Carry;

    // Instantiate the first block with external Carry-in
    CLA_4bit block0(A[3:0], B[3:0], Cin, Sum[3:0], Carry[0]);

    // Instantiate the intermediate blocks
    genvar i;
    generate
        for (i = 1; i < 16; i++) begin : gen_CLA_blocks
            CLA_4bit block(A[4*i+3:4*i], B[4*i+3:4*i], Carry[i-1], Sum[4*i+3:4*i], Carry[i]);
        end
    endgenerate

    // The final Carry-out
    assign Cout = Carry[15];

    //Overflow assignment 
    assign Overflow = ((A[63] == B[63]) && (Result[63] != A[63]));

endmodule
