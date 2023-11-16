//Testbench for ALU.sv, ALU_Control.sv, ALU operations
`timescale 1ns / 1ps
`include "Include_Files.sv"
module ALU_TB();

    // Clock signal for synchronous operations
    reg Clk;
    // Inputs
    reg signed [63:0] A, B;
    reg [6:0] ALUOp;
    reg [2:0] Func3;
    reg [6:0] Func7;
    reg signed [63:0] A_gold, B_gold;
    reg Cin;

    // Outputs
    wire signed [63:0] Result, Result_gold;
    wire Zero;
    wire Cout;
    wire Overflow;
    // Intermediate wires for connecting ALU_Control to ALU
    wire [3:0] ALUCtrl;

    // Instantiate the ALU_Control Module
    ALU_Control uut_control(
        .ALUOp(ALUOp),
        .Func3(Func3),
        .Func7(Func7),
        .ALUCtrl(ALUCtrl)
    );

    // Instantiate the ALU Module
    ALU uut_alu(
        .A(A),
        .B(B),
        .ALUCtrl(ALUCtrl),
        .Result(Result),
        .Zero(Zero)
    );

    //Instantiate the CLA Module
    CLA_64bit uut_cla(
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Result),
        .Cout(Cout)
    );

    //Instantiate the Subtractor Module
    Subtractor_64bit uut_sub(
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Result),
        .Cout(Cout)
    );

    // Clock generation
    initial Clk = 0;
    always #5 Clk = ~Clk; // Toggle clock every 5ns

    // Testbench logic
    initial begin
        // Initialize Inputs
        A = 0;
        B = 0;
        A_gold = 0;
        B_gold = 0;
        ALUOp = 0;
        Func3 = 0;
        Func7 = 0;
        Cin = 0;

        // Test Cases for ADD 
        //ADD1: basic addition
        A = 20;
        B = 22;
        A_gold = 20;
        B_gold = 22;
        Cin = 0;
        Result_gold = A_gold + B_gold + Cin;
        ALUOp = 7'b0110011; // R-type
        Func3 = 3'b000; // ADD
        Func7 = 7'b0000000; // ADD_OP
        #10; // Wait for 10 ns
        //ADD2: basic addition cin = 1
        A = 10;
        B = 10;
        A_gold = 10;
        B_gold = 10;
        Cin = 1;
        //ADD3: Overflow check
        A = 64'd1;
        B = 64'd1;
        A_gold = 64'd1;
        B_gold = 64'd1;
        Cin = 1;

        // Test Cases SUB
        //SUB1: basic subtraction
        A = 50;
        B = 20;
        A_gold = 50;
        B_gold = 20;
        Result_gold = A_gold - B_gold;
        Func3 = 3'b000;
        Func7 = 7'b0100000; // SUB_OP
        #10; // Wait for 10 ns
        //SUB2: Overflow check
        A = 64'd0;
        B = 64'd1;
        A_gold = 64'd0;
        B_gold = 64'd1;
        Result_gold = A_gold - B_gold;

        // Test Case 3: MUL
        A = 3;
        B = 4;
        A_gold = 3;
        B_gold = 4;
        Result_gold = A_gold * B_gold;
        Func3 = 3'b000; // MUL
        Func7 = 7'b0000001; // MUL_OP
        #10; // Wait for 10 ns

        // Test Case 4: DIV
        A = 40;
        B = 5;
        A_gold = 40;
        B_gold = 5;
        Result_gold = A_gold / B_gold;
        Func3 = 3'b100; // DIV
        Func7 = 7'b0000001; // DIV_OP
        #10; // Wait for 10 ns

        // Test Case 5: SLT
        A = 5;
        B = 10;
        A_gold = 5;
        B_gold = 10;
        if(A_gold < B_gold) begin
            Result_gold = 1;
        end else begin
            Result_gold = 0;
        end
        Func3 = 3'b010; // SLT
        Func7 = 7'b0000000; // SLT_OP
        #10; // Wait for 10 ns

        // Test Case 6: AND
        A = 12;
        B = 5;
        A_gold = 12;
        B_gold = 5;
        Result_gold = A_gold & B_gold;
        Func3 = 3'b111; // AND
        Func7 = 7'b0000000; // AND_OP
        #10; 
        // End of test cases
        // Finish Simulation
        $finish;
    end

    // Comparison logic
    always @(posedge Clk) begin
        if (Overflow) begin
            $display("WARNING!!! Overflow occured");
        end
        else begin
        if (Result != Result_gold) begin
            $display("Mismatch: A = %d, B = %d, Expected = %d, Got = %d", A, B, Result_gold, Result);
            end 
        else begin
            $display("Test Passed: A = %d, B = %d, Result_gold = %d, Result = %d", A, B, Result_gold, Result);
            end
        end
    end
endmodule



