//Testbench for ALU.sv, ALU_Control.sv, ALU operations
`timescale 1ns / 1ps
module ALU_TB();

    // Clock signal for synchronous operations
    reg Clk;
    // Inputs
    reg signed [63:0] A, B;
    reg [6:0] ALUOp;
    reg [2:0] Func3;
    reg [6:0] Func7;
    reg signed [63:0] A_gold, B_gold, Result_gold;
    reg Cin;
    reg [31:0] reg1;
    reg [31:0] reg2;
    reg [63:0] temp_random0, temp_random1;
    reg Rst;
    reg we;
    reg [4:0] rd;
    reg [63:0] wd;
    reg [4:0] rs1, rs2;
    wire [63:0] rd1, rd2;
    // Outputs
    wire signed [63:0] Result;
    wire Zero;
    wire Cout;
    wire Overflow;
    // Intermediate wires for connecting ALU_Control to ALU
    wire [3:0] ALUCtrl;
    integer i;
    integer passed=0;
    integer total=0;
    // Instantiate the ALU_Control Module
    ALU_Control uut_control(
        .ALUOp(ALUOp),
        .Func3(Func3),
        .Func7(Func7),
        .ALUCtrl(ALUCtrl)
    );


    // Instantiate the register module
    register_file register_instance(
        .clk(Clk),
        .rst(Rst),
        .we(we),
        .rd(rd),
        .wd(wd),
        .rs1(rs1),
        .rs2(rs2),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Instantiate the ALU Module
    ALU uut_alu(
        .A(A),
        .B(B),
        .Cin(Cin),
        .ALUCtrl(ALUCtrl),
        .Result(Result),
        .Zero(Zero),
        .Overflow(Overflow)
    );
    // Clock generation
    initial Clk = 0;
    always #5 Clk = ~Clk; // Toggle clock every 5ns

    // Testbench logic
    initial begin
        // Initialize Inputs
        Rst = 1;
        A = 0;
        B = 0;
        A_gold = 0;
        B_gold = 0;
        Result_gold = 0;
        ALUOp = 0;
        Func3 = 0;
        Func7 = 0;
        Cin = 0;
        passed = 0;
        total = 0;
        #10;
        Rst = 0;
        #10;
        #10;
        // Test Cases for ADD 

        //ADD1: basic addition
        // Write the value 20 to register 1
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 20;
        #10; 
        // Write the value 22 to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 22;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        // At this point, the values of registers 1 and 2 are available on rd1 and rd2, respectively
        A = rd1;
        B = rd2;
        A_gold = 20;
        B_gold = 22;
        Cin = 0;
        Result_gold = A_gold + B_gold + Cin;
        ALUOp = 7'b0110011; // R-type
        Func3 = 3'b000; // ADD
        Func7 = 7'b0000000; // ADD_OP
        #10;
        //End of ADD1
        //Reset between operations
        #10;
        Rst = 1;
        #10;
        Rst = 0;
        #10;

        //ADD2: basic addition cin = 1
        // Write the value 10 to register 1
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 10;
        #10; 
        // Write the value 10 to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 10;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        // At this point, the values of registers 1 and 2 are available on rd1 and rd2, respectively
        A = rd1;
        B = rd2;
        A_gold = 10;
        B_gold = 10;
        Cin = 1;
        Result_gold = A_gold + B_gold + Cin;
        #10;
        //End of ADD2
        //Reset between operations
        #10;
        Rst = 1;
        #10;
        Rst = 0;
        #10;


        //ADD3: Overflow check
        // Write the value 64'd1; to register 1
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 64'd1;;
        #10; 
        // Write the value 64'd1; to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 64'd1;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        A = rd1;
        B = rd2;
        A_gold = 64'd1;
        B_gold = 64'd1;
        Cin = 1;
        Result_gold = A_gold + B_gold + Cin;
        #10;
        //End of ADD3
        //Reset between operations
        #10;
        Rst = 1;
        #10;
        Rst = 0;
        #10;

        //ADD4:Random check
        for(i=0;i<100;i=i+1) begin //Loop to run throgugh 100 random test cases
            // Generate a random value
            temp_random0 = $random;
            temp_random1 = $random;
            // Write the value temp_random0 to register 1
            we <= 1;
            rd <= 5'b00001; // Address of register 1
            wd <= temp_random0;
            #10; 
            // Write the value temp_random1 to register 2
            rd <= 5'b00010; // Address of register 2
            wd <= temp_random1;
            #10; 
            // Disable write enable
            we <= 0;
            // Read the values from registers 1 and 2
            rs1 <= 5'b00001; // Address of register 1
            rs2 <= 5'b00010; // Address of register 2
            #10;
            A = rd1;
            B = rd2;
            A_gold = temp_random0;
            B_gold = temp_random1;
            Result_gold = A_gold + B_gold + Cin;
            #10;
            //End of ADD
            //Reset between operations
            #10;
            Rst = 1;
            #10;
            Rst = 0;
            #10;
            #10;
        end

        // Test Cases SUB
        //SUB1: basic subtraction
        // Write the value 50 to register 1
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 50;
        #10; 
        // Write the value 20 to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 20;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        A = rd1;
        B = rd2;
        A_gold = 50;
        B_gold = 20;
        Result_gold = A_gold - B_gold;
        Func3 = 3'b000; // SUB
        Func7 = 7'b0100000; // SUB_OP
        #10;        //Reset between operations
        #10;
        Rst = 1;
        #10;
        Rst = 0;
        #10;
        #10; // Wait for 10 ns

        //SUB2: Overflow check
        // Write the value 64'd0 to register 1
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 64'd0;
        #10; 
        // Write the value 64'd1 to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 64'd1;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        A = rd1;
        B = rd2;
        A_gold = 64'd0;
        B_gold = 64'd1;
        Result_gold = A_gold - B_gold;
        #10;        //Reset between operations
        Rst = 1;
        #10;
        Rst = 0;
        #10;

        for(i=0;i<100;i=i+1) begin //Loop to run throgugh 100 random test cases
            // Generate a random value
            temp_random0 = $random;
            temp_random1 = $random;
            // Write the value temp_random0 to register 1
            we <= 1;
            rd <= 5'b00001; // Address of register 1
            wd <= temp_random0;
            #10; 
            // Write the value temp_random1 to register 2
            rd <= 5'b00010; // Address of register 2
            wd <= temp_random1;
            #10; 
            // Disable write enable
            we <= 0;
            // Read the values from registers 1 and 2
            rs1 <= 5'b00001; // Address of register 1
            rs2 <= 5'b00010; // Address of register 2
            #10;
            A = rd1;
            B = rd2;
            A_gold = temp_random0;
            B_gold = temp_random1;
            Result_gold = A_gold - B_gold;
            #10;
            #10;        //Reset between operations
            Rst = 1;
            #10;
            Rst = 0;
            #10;
        end

        // Test Case 3: MUL
        // Write the value 3 to register 1
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 3;
        #10; 
        // Write the value 4 to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 4;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        A = rd1;
        B = rd2;
        A_gold = 3;
        B_gold = 4;
        Result_gold = A_gold * B_gold;
        Func3 = 3'b000; // MUL
        Func7 = 7'b0000001; // MUL_OP
        #10; // Wait for 10 ns
        #10;        //Reset between operations
        Rst = 1;
        #10;
        Rst = 0;
        #10;

        for(i=0;i<100;i=i+1) begin //Loop to run throgugh 100 random test cases
            // Generate a random value
            temp_random0 = $random;
            temp_random1 = $random;
            // Write the value temp_random0 to register 1
            we <= 1;
            rd <= 5'b00001; // Address of register 1
            wd <= temp_random0;
            #10; 
            // Write the value temp_random1 to register 2
            rd <= 5'b00010; // Address of register 2
            wd <= temp_random1;
            #10; 
            // Disable write enable
            we <= 0;
            // Read the values from registers 1 and 2
            rs1 <= 5'b00001; // Address of register 1
            rs2 <= 5'b00010; // Address of register 2
            #10;
            A = rd1;
            B = rd2;
            A_gold = temp_random0;
            B_gold = temp_random1;
            Result_gold = A_gold * B_gold;
            #10;
            #10;        //Reset between operations
            Rst = 1;
            #10;
            Rst = 0;
            #10;
        end
        
        // Test Case 4: DIV
        // Write the value 40 to register 1
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 40;
        #10; 
        // Write the value 5 to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 5;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        A = rd1;
        B = rd2;
        A_gold = 40;
        B_gold = 5;
        Result_gold = A_gold / B_gold;
        Func3 = 3'b100; // DIV
        Func7 = 7'b0000001; // DIV_OP
        #10; // Wait for 10 ns
        #10;        //Reset between operations
        Rst = 1;
        #10;
        Rst = 0;
        #10;
        #10; // Wait for 10 ns

        // Test Case 5: SLT
        we <= 1;
        rd <= 5'b00001; // Address of register 1
        wd <= 5;
        #10; 
        // Write the value 5 to register 2
        rd <= 5'b00010; // Address of register 2
        wd <= 10;
        #10; 
        // Disable write enable
        we <= 0;
        // Read the values from registers 1 and 2
        rs1 <= 5'b00001; // Address of register 1
        rs2 <= 5'b00010; // Address of register 2
        #10;
        A = rd1;
        B = rd2;
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
        $display("Passed %d/%d tests", passed, total); //Display totals for tests
        $finish;
    end

    // Comparison logic
    always @(posedge Clk) begin
        if (Overflow) begin
            $display("WARNING!!! Overflow occured");
        end
        else begin
        if (Result !== Result_gold) begin
            $display("Mismatch: A = %d, B = %d, Expected = %d, Got = %d", A, B, Result_gold, Result);
        end 
        else begin
            $display("Test Passed: A = %d, B = %d, Result_gold = %d, Result = %d", A, B, Result_gold, Result);
            passed = passed + 1;
        end
        total = total + 1; // Increment total number of tests 
        end
    end
endmodule



