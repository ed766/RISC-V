//This is a Dadda Multiplier with 64-bit inputs and 128-bit output.

module Dadda_Multiplier (
    signed input [63:0] A, //A
    signed input [63:0] B, //B
    output [127:0] Result
);
    //All intermediate matrices to be used in the Dadda Multiplier
    wire shifted_matrix [126:0][63:0];
    wire initial_tree [126:0] [63:0];
    wire partial_sums_previous [126:0] [63:0];
    wire partial_sums_dynamic [126:0] [63:0];
    wire final_sum [127:0];
    //Various integers used for the generate loops
    genvar i,j,z;
    wire Cin_input[127:0];
    wire Cout_output[127:0];
    wire Result_output[127:0];
    parameter NUM_LOOPS = 10; // Number of loops
    parameter LOOP_VALUES[NUM_LOOPS:0] = '{63,42,28,19,13,9,6,4,3,2,1}; // Values for each loop
    wire has_carryout[127:0][63:0];
    wire next_carry;
    // Generate partial products, this creates a shifted matrix, where the the first row is normal and the rest are shifting by the number of bits 
    generate
        for (i = 0; i < 64; i++) begin : gen_shifted_matrix
            for(j = 0; j < 64; j++) begin: gen_partial_bits
                assign shifted_matrix[i][i+j] = A[j] & B[i];
            end
        end
    endgenerate

    // Generate Tree, this is done by shifting the bits up by the difference between the column and the midpoint
    generate
        for (i = 0; i < 64; i++) begin : gen_tree
            for(j = 0; j < 127; j++) begin: gen_tree_bits
                if (j < 64) begin
                    assign initial_tree [i][j] = shifted_matrix [i][j]; //This keeps the bits in the same place if they are in the are the right side of the tree
                end
                else if (i>0 && j>63) begin
                    assign initial_tree [i-(j-63)][j] = shifted_matrix [i][j]; //Shifts up the bits by the difference between the column and the midpoint, ie it'll shift up the left side
                end 
                else begin
                    assign initial_tree [i][j] = 1'b0;
                end
            end
        end
    endgenerate

    //Reduces Tree from 64 to 63 bits, only affects 1 row due to nature of tree
    generate
            for(i = 0; i < 64; i++) begin : gen_partial_sums_63
                for(j = 0; j < 127; j++) begin : gen_partial_sums_63
                    if((i == 63 && j==63) ) begin
                        Half_Adder HA0(.A(initial_tree[i][j]), .B(initial_tree[i+1][j]), .Result(partial_sums_63[i][j]), .Cout(Cin_input[0]));
                    end
                    else if(j == 63) begin
                        assign partial_sums_63[i][j] = initial_tree[i][j]; //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                end
            end
    endgenerate
   // Dynamic generation of further iterations based on current LOOP_Value
    generate
    for (int step = 1; step < NUM_LOOPS-1; step++) begin : dynamic_column_reduction
            for (int k = 0; k < 127; k++) begin
                for (int l = 0; l < LOOP_VALUES[step]; l++) begin
                    if(has_carryout[k][l]) begin
                        assign Cin_input[k] = 1;
                    end
                    else begin
                        assign Cin_input[k] = 0;
                        has_carryout[k][l] = 0;     //Reset carry for each step
                    end
                end
            end
        for (int j = 0; j < 127; j++) begin : dynamic_column_reduction
            for (int i = 0; i < LOOP_VALUES[step]; i++) begin : dynamic_row_reduction
                if (j < LOOP_VALUES[step] || j > 63 + LOOP_VALUES[step]) begin
                    assign partial_sums_dynamic[i][j] = partial_sums_previous[i][j];
                end 
                else begin : Dynamic_Reduction
                    if ((abs(i - j) - LOOP_VALUES[step] > 2) || 
                        (abs(i - j) - LOOP_VALUES[step] == 2 && has_carryout[i][j] === 1)) begin
                        Full_Adder fa_inst (
                            .A(partial_sums_previous[i][j]), 
                            .B(partial_sums_previous[i + 1][j]), 
                            .Cin(Cin_input[j]), 
                            .Result(partial_sums_dynamic[i][j]), 
                            .Cout(Cout_output[j])
                        );
                    end 
                    else if (abs(i - j) - LOOP_VALUES[step] == 2 && has_carryout[i][j] === 0) begin
                        Half_Adder ha_inst (
                            .A(partial_sums_previous[i][j]), 
                            .B(partial_sums_previous[i + 1][j]), 
                            .Result(partial_sums_dynamic[i][j]), 
                            .Cout(Cin_output[j])
                        );
                    end

                if (/* condition to check if carry-over is needed */) begin
                    assign Cin_input[j + 1] = Cout_output[j];
                    assign has_carryout[i][j] = 1;
                end 
                else begin
                    // Reset the carry-in for the next iteration if no carry-over is needed
                    assign Cin_input[j + 1] = 0;
                    assign has_carryout[i][j] = 0
                end
            end
        end
    end
    end
endgenerate
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j++) begin : column_reduction_1
            for(i = 0; i <  LOOP_VALUES[10]; i++) begin : row_reduction_1
                for(z=0; z< abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(partial_sums_2[i][j]), 
                                .B(partial_sums_2[i+1][j]), 
                                .Result(Result[z]), 
                                .Cout(Cout_output[z])
                            );                            
                        end
                    end
                end
    endgenerate
    // Assign output
endmodule

