//This is the full 64 bit CLA adder that takes in two 64 bit numbers and outputs the Result and Carry out, it is made up of 16 4 bit CLA adders and is used by the ALU
`include "CLA_4bit.sv"
module CLA_64bit(
    input signed [63:0] A,
    input signed [63:0] B,
    input Cin,
    output signed [63:0] Result,
    output Cout,
    output Overflow
);
    wire [15:0] Carry;

    // Instantiate the first block with external Carry-in
        CLA_4bit block0(
        .A(A[3:0]),
        .B(B[3:0]),
        .Cin(Cin), // Use the external Cin for the first block
        .Result(Result[3:0]),
        .Cout(Carry[0]) // The carry out goes to the Carry wire
    );

    // Instantiate the intermediate blocks
   genvar i;
   generate
   for (i = 1; i < 16; i = i + 1) begin : gen_CLA_blocks
        CLA_4bit block(
            .A(A[4*i+3:4*i]),
            .B(B[4*i+3:4*i]),
            .Cin(Carry[i-1]), 
            .Result(Result[4*i+3:4*i]),
            .Cout(Carry[i]) 
        );
    end
    endgenerate


    // The final Carry-out
    assign Cout = Carry[15];

    //Overflow assignment 
    assign Overflow = ((A[63] == B[63]) && (Result[63] != A[63]));

endmodule
