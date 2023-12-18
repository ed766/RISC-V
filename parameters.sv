// parameters.sv
`ifndef Parameters_SV
`define Parameters_SV

parameter R_Type = 7'b0110011;
parameter ADD_Func7 = 7'b0000000;
parameter ADDANDSLT_Func7 = 7'b0000000;
parameter AND_Func7 = 7'b0000000;
parameter MULDIV_Func7 = 7'b0000001;
parameter SLT_Func7 = 7'b0000000;
parameter SUB_Func7 = 7'b0100000;
parameter ADDMULSUB_Func3 = 3'b000;
parameter SLT_Func3 = 3'b010;
parameter DIV_Func3 = 3'b100;
parameter AND_Func3 = 3'b111;
// Define other parameters as needed

`endif