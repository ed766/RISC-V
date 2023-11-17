//This is the Full Adder module that takes in two bits and a carry in and outputs the result and carry out. Used in Dadda Multiplier 
module Full_Adder(
    input A,
    input B,
    input Cin,
    output Result,
    output Cout
);
    Result = A ^ B ^ Cin;
    Cout = (A && B) || (Cin && A) || (Cin && A);
endmodule