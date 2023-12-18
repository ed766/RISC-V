//THis module is the main CPU core that integrates the register as well as the ALU and ALU control modules
module CPU_Core(
    input [63:0] A,
    input [63:0] B,
    input Cin,
    input Clk,
    input [6:0] Opcode,
    input [2:0] Func3,
    input [6:0] Func7,
    input rst,
    input we, // write enable
    input [4:0] rs1, // read select 1
    input [4:0] rs2, // read select 2
    input [4:0] rd, // write select
    input [63:0] wd, // write data (64-bit)
    output [63:0] rd1, // read data 1 (64-bit)
    output [63:0] rd2, // read data 2 (64-bit)
    output signed [63:0] Result,
    // Additional Inputs/Outputs for instruction memory and program counter
    input [63:0] instr_address, // Current instruction address
    output [63:0] next_instr_address // Address of the next instruction
);
    // Internal signals
    reg [31:0] mem [0:2**64-1]; // 64-bit addressable memory
    wire [3:0] ALUCtrl;

    // Instantiate ALU
    ALU ALUInstance(
        .A(A),
        .B(B),
        .Cin(Cin),
        .ALUCtrl(ALUCtrl),
        .Result(Result),
        .Zero(Zero),
        .Overflow(Overflow)
    );

    // Instantiate ALU Control
    ALU_Control ALUControlInstance(
        .ALUOp(Opcode),
        .Func3(Func3),
        .Func7(Func7),
        .ALUCtrl(ALUCtrl)
    );

    // Instantiate Register File
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

    // Instruction Memory (Placeholder for actual memory interface)
    // Instruction Decode Logic

    // Program Counter Logic
    reg [63:0] pc;


endmodule