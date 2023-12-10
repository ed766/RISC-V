//This is a Dadda Multiplier with 64-bit inputs and 128-bit output. This is not used in the current ALU implementation, as it does not work, but is included for reference.

module Dadda_Multiplier (
    input signed [63:0] A, //A
    input signed [63:0] B, //B
    output signed [127:0] Result
); 
    parameter bit [5:0] LOOP_VALUES[11] = '{6'd1, 6'd2, 6'd3, 6'd4, 6'd6, 6'd9, 6'd13, 6'd19, 6'd28, 6'd42, 6'd63};
    //All intermediate matrices to be used in the Dadda Multiplier
    wire shifted_matrix [126:0][63:0];
    wire initial_tree [126:0] [63:0];
    wire partial_sums_previous [126:0] [63:0];
    wire partial_sums_dynamic [126:0] [63:0];
    //Various integers used for the generate loops
    genvar i,j,z,step,K,L;
    //Various wires used for the generate loops
    wire [127:0] Result_output;
    wire [10:0] [127:0] [63:0] Cout_output;
    // Generate partial products, this creates a shifted matrix, where the the first row is normal and the rest are shifting by the number of bits 
    generate
        for (i = 0; i < 64; i++) begin : gen_shifted_matrix
            for(j = 0; j < 64-i; j++) begin: gen_partial_bits
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
                else if (i>=(j-63)) begin
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
                        Half_Adder HA0(.A(initial_tree[i][j]), .B(initial_tree[i+1][j]), .Result(partial_sums_previous[i][j]), .Cout(Cout_output[0][i][j]));
                    end
                    else begin
                        assign partial_sums_previous[i][j] = initial_tree[i][j]; //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                end
            end
    endgenerate
   // This block runs at the end of each generate loop in order to check wether to reset carryout matrix and transfer carryin matrix
    generate //This iterates the tree from 63 bits to 2 bits
        for (step = 1; step < 11; step++) begin : step_loop
            for (j = 0; j < 127; j++) begin : dynamic_column_reduction
                for (i = 0; i < LOOP_VALUES[step]; i++) begin : dynamic_row_reduction
                    if (j < LOOP_VALUES[step] || j > 63 + LOOP_VALUES[step]) begin
                        assign partial_sums_dynamic[i][j] = partial_sums_previous[i][j];  //This copies the previous partial sums if the column is not in the range of the current loop value
                    end 
                    else begin : Dynamic_Reduction
                        if (abs(i - j) - LOOP_VALUES[step] >= 2) begin // This checks if the column is in the range of the current loop value and if it needs a carryin, then it uses a full adder, as a full adder works wether or not a carryin is 0 or 1 
                            Full_Adder fa_inst (
                                .A((i - 1) >= 0 ? partial_sums_previous[i - 1][j] : 0),
                                .B(partial_sums_previous[i][j]), 
                                .Cin(Cout_output[step][i-1][j]), 
                                .Result(partial_sums_dynamic[i][j]), 
                                .Cout(Cout_output[step][i][j])
                            ); 
                        end
                        if(i == LOOP_VALUES[step]-2) begin
                            assign partial_sums_dynamic[0][j+1] = Cout_output[step][i][j]; //This copies the carryout from the previous column to the current column
                        end
                        end
                    end
                end
            end
        if(step == 11) begin: final_reduction
            for(i = 0; i < 128; i++) begin : final_assignment
                assign Result_output[i] = partial_sums_dynamic[0][127];
            end
        end
    endgenerate

    // Assign output
endmodule

