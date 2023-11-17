//This is the Full Adder module that takes in two bits and outputs the result and carry out. Used in Dadda Multiplier 
module Half_Adder(
    input A,
    input B,
    output Result,
    output Cout
);
    Result = A ^ B;
    Cout = A && B;

endmodule