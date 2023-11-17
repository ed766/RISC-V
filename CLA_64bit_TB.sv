`timescale 1ns / 1ps
`include "CLA_64bit.sv"
module CLA_64bit_TB;

    // Inputs
    reg signed [63:0] A;
    reg signed [63:0] B;
    reg Cin;

    // Outputs
    wire signed [63:0] Result;
    wire Cout;
    wire Overflow;

    // Instantiate the Unit Under Test (UUT)
    CLA_64bit uut (
        .A(A), 
        .B(B), 
        .Cin(Cin), 
        .Result(Result), 
        .Cout(Cout),
        .Overflow(Overflow)
    );

    initial begin
        // Initialize Inputs
        A = 0;
        B = 0;
        Cin = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        // Add stimulus here
        A = 64'hFFFFFFFFFFFFFFFF; // All 1's
        B = 64'h0000000000000001; // Plus 1
        Cin = 0;
        #10; // Wait for the addition to take place

        A = 64'h7FFFFFFFFFFFFFFF; // Largest positive number
        B = 64'h0000000000000001; // Plus 1 should overflow
        Cin = 0;
        #10;
        A = 64'd1;
        B = 64'd1;
        Cin = 1;
        #10;
        // More test vectors can be added here

    end
      
endmodule
