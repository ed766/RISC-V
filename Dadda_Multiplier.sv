//This is a Dadda Multiplier with 64-bit inputs and 128-bit output.

module Dadda_Multiplier (
    input [63:0] multiplicand, //A
    input [63:0] multiplier, //B
    output [127:0] product
);
    //All intermediate matrices to be used in the Dadda Multiplier
    wire shifted_matrix [63:0] [126:0];
    wire initial_tree [63:0] [126:0];
    wire partial_sums_63 [62:0] [126:0];
    wire partial_sums_42 [41:0] [126:0];
    wire partial_sums_28 [27:0] [126:0];
    wire partial_sums_19 [18:0] [126:0];
    wire partial_sums_13 [14:0] [126:0];
    wire partial_sums_9 [8:0] [126:0];
    wire partial_sums_6 [5:0] [126:0];
    wire partial_sums_4 [3:0] [126:0];
    wire partial_sums_3 [2:0] [126:0];
    wire partial_sums_2 [1:0] [126:0];
    wire final_sum [127:0];
    //Various integers used for the generate loops
    integer i,j,z;
    integer k = 0;
    integer numberOfAdders;
    integer summing;
    integer number_of_rows;
    integer last_n;
    integer current_n;
    wire Cin_input[127:0];
    wire Cout_output[127:0];
    wire Result_output[127:0];
    // Generate partial products, this creates a shifted matrix, where the the first row is normal and the rest are shifting by the number of bits 
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_shifted_matrix
            for(j = 0; j < 64; j = j + 1) begin: gen_partial_bits
                assign shifted_matrix[i][i+j] = multiplicand[j] & multiplier[i];
            end
        end
    endgenerate

    // Generate Tree, this is done by shifting the bits up by the difference between the column and the midpoint
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_tree
            for(j = 0; j < 127; j = j + 1) begin: gen_tree_bits
                if (j < 64) begin
                    assign initial_tree [i][j] = shifted_matrix [i][j] //This keeps the bits in the same place if they are in the are the right side of the tree
                end
                else if (i>0) begin
                    assign initial_tree [i-(j-63)][j] = shifted_matrix [i][j] //Shifts up the bits by the difference between the column and the midpoint, ie it'll shift up the left side
                end 
                else begin
                    assign initial_tree [i][j] = 1'b0;
                end
            end
        end
    endgenerate

    //Reduces Tree from 64 to 63 bits, only affects 1 row due to nature of tree
    generate
        for(i = 0; i < 64; i = i + 1) begin : gen_partial_sums_63
            for(j = 0; j < 127; j = j + 1) begin : gen_partial_sums_63
                if(j != 63) begin
                    assign partial_sums_63[i][j] = initial_tree[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                end
                else if(j == 63) begin
                    Half_Adder HA0(.A(initial_tree[i][j]), B(initial_tree[i+1][j]), .Result(Result_output[0]), .Cout(Cin_input[0]));
                    assign partial_sums_63[i][j] = Result_output[0];
                end
            end
        end
    endgenerate

    //This reduces the loop from 63 to 42 bits since n=42, this step is far more involved as a result of having a lot more reductions 
    current_n = 42; //Curent  Loop Iteration
    last_n = 63; //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_42
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_42
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_42[i][j] = partial_sums_63[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_42
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (k == 0 || abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder
                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_42[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_42[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    current_n = 28;
    last_n = 42; //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_28
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_28
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_28[i][j] = partial_sums_42[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_28
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder

                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_28[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_28[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This reduces the loop from 28 to 19 bits 
    current_n = 19; //Curent  Loop Iteration
    last_n = 28; //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_19
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_19
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_19[i][j] = partial_sums_28[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_19
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder

                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_19[i][j] = Result_output[k];                            
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0]])
                            );
                            assign partial_sums_19[i][j] = Result_output[k];                            
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This reduces the loop from 19 to 13 bits 
    current_n = 13; //Curent  Loop Iteration
    last_n = 19; //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_13
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_13
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_13[i][j] = partial_sums_19[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_13
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder

                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_13[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_13[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This reduces the loop from 13 to 9 bits 
    current_n = 9; //Curent  Loop Iteration
    last_n = 13; //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_9
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_9
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_9[i][j] = partial_sums_13[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_9
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder

                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_9[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_9[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This reduces the loop from 9 to 6 bits 
    current_n = 6; //Curent  Loop Iteration
    last_n = 9; //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_6
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_6
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_6[i][j] = partial_sums_9[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_6
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder

                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_6[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_6[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This reduces the loop from 6 to 4 bits 
    current_n = 4; //Curent  Loop Iteration
    last_n = 6; //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_4
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_4
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_4[i][j] = partial_sums_6[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_4
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs(i-j)-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder
                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_4[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_4[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This reduces the loop from 4 to 3 bits 
    current_n = 3 ; //Curent  Loop Iteration
    last_n = 4 //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_3
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_3
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_3[i][j] = partial_sums_4[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                    end
                else begin: Reduction_3
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder

                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_3[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_3[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This reduces the loop from 3 to 2 bits 
    current_n = 2 ; //Curent  Loop Iteration
    last_n = 3 //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_2
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_2
                if(j < current_n || j > 63+.5*(current_n) ) begin
                    assign partial_sums_2[i][j] = partial_sums_3[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                end
                else begin: Reduction_2
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                        if (abs((i-j))-z > 2) begin //K==0 is due to having the half adder from the first iteration of the tree in the prior generate loop. The second condition is to check if the difference between the row and column, minus the number of reductions already done is greater than 2, if it is, then it is a full adder, otherwise it is a half adder

                            Full_Adder fa_inst ( //Full Adder instantiation
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Cin(Cin_input[k]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign partial_sums_2[i][j] = Result_output[k];
                            k=k+1;
                        end 
                        else if ( abs((i-j))-z == 2) begin //This is the case where the difference between the row and column, minus the number of reductions already done is equal to 2, if it is, then it is a half adder, otherwise it is a full adder
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cin_input[0])
                            );
                            assign partial_sums_2[i][j] = Result_output[k];
                            k=k+1;
                        end
                    end
                end
            end
        end
    endgenerate

    //This is the final loop that sums from 2 to 1 bits, just uses Half Adders since only two bits are being summed
    current_n = 1 ; //Curent  Loop Iteration
    last_n = 2 //Prior loop iteration
    k = 0;   
    //Dynamic Instantiation based on number of Adders needed
    generate
        for(j = 0; j < 127; j = j + 1) begin : column_reduction_1
            for(i = 0; i <  last_n-1; i = i + 1) begin : row_reduction_1
                            Half_Adder ha_inst ( //Half Adder instantiation, should only be used once per column 
                                .A(A_input[i]), 
                                .B(B_input[i+1]), 
                                .Result(Result_output[k]), 
                                .Cout(Cout_output[k])
                            );
                            assign final_sum[j] = Result_output[k];
                            k=k+1;
                        end
                    end
    endgenerate

    // Assign output
    assign product = final_sum;

endmodule

