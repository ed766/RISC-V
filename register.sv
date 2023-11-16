//This is the main register file, 64 bits wide and 32 registers deep

module register_file(
    input wire clk,
    input wire rst,
    input wire we, // write enable
    input wire [4:0] rs1, // read select 1
    input wire [4:0] rs2, // read select 2
    input wire [4:0] rd, // write select
    input wire [63:0] wd, // write data (64-bit)
    output wire [63:0] rd1, // read data 1 (64-bit)
    output wire [63:0] rd2 // read data 2 (64-bit)
);

// Declare 32 registers, each 64 bits wide
reg [63:0] registers [31:0];

// Read logic (combinational)
assign rd1 = (rs1 != 0) ? registers[rs1] : 64'b0; // if rs1 is 0, force read 0 (64-bit zero)
assign rd2 = (rs2 != 0) ? registers[rs2] : 64'b0; // if rs2 is 0, force read 0 (64-bit zero)

// Write logic (sequential)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Asynchronous reset logic, sets all registers to 0 ( 64-bit zero)
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 64'b0;
        end
    end else if (we && (rd != 0)) begin
        // Write to the register on the rising edge of the clock if write enable is high
        // Do not write if rd is 0, as it is the zero register (no change needed here)
        registers[rd] <= wd;
    end
end

endmodule
