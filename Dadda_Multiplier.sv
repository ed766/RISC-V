//This is a Dadda Multiplier with 64-bit inputs and 128-bit output.

module dadda_multiplier (
    input [63:0] multiplicand,
    input [63:0] multiplier,
    output [127:0] product
);

    wire partial_products [63:0] [126:0];
    wire partial_products_new [63:0] [126:0];
    wire partial_sums_1 [63:0] [126:0];
    wire partial_sums_2 [62:0] [126:0];
    wire final_sum [127:0];
    integer i,j,z;
    integer k=0;
    integer numberOfAdders;
    integer summing;
    wire result_HA0;

    wire Cout_HA0;

    wire Cout_FA0;
    wire Cout_FA1;

    wire Cin_input[127:0];
    wire Cout_output[127:0];
    wire Result_output[127:0];
    // Generate partial products, this creates a shifted matrix, where the the first row is normal and the rest are shifting by the number of bits 
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_partial_products
            for(j = 0; j < 64; j = j + 1) begin: gen_partial_bits
            assign partial_products[i][i+j] = multiplicand[j] & multiplier[i];
            end
        end
    endgenerate

    // Generate Tree, this is done by shifting the bits up by the difference between the column and the midpoint
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_partial_products
            for(j = 0; j < 127; j = j + 1) begin: gen_partial_bits
                if (j < 64) begin
                    assign partial_products_new [i][j] = partial_products [i][j] //This keeps the bits in the same place if they are in the are the right side of the tree
                end
                else if (i>0) begin
                    assign partial_products_new [i-(j-63)][j] = partial_products [i][j] //Shifts up the bits by the difference between the column and the midpoint, ie it'll shift up the left side
                end 
                else begin
                    assign partial_products_new [i][j] = 1'b0;
                end
            end
        end
    endgenerate
    //Reduces Tree from 64 to 63 bits, only affects 3 rows due to nature of tree
    generate
        for(i = 0; i < 64; i = i + 1) begin : gen_partial_sums_1
            for(j = 0; j < 127; j = j + 1) begin : gen_partial_sums_1
                if(j!= 63) begin
                    assign partial_sums_1[i][j] = partial_products_new[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                end
                else if(j == 63) begin
                    Half_Adder HA0(.A(partial_products_new[i][j]), B(partial_products_new[i+1][j]), .Result(Result_output[0]), .Cout(Cin_input[0]));
                    assign partial_sums_1[i][j] =  partial_result;
                end
            end
        end
    endgenerate
    //This reduces the loop from 63 to 42 bits since n=42, this step is far more involved as a result of having a lot more reductions 
    //Dynamic Instantiation based on number of Adders needed
    summing = 21 //Difference between n and n-1
    numberOfAdders = (summing^2+summing)/2
    generate
    for(i = 0; i < 62; i = i + 1) begin : gen_partial_sums_2
            for(j = 0; j < 127; j = j + 1) begin : gen_partial_sums_2
                if(j < 42 || j > 84) begin
                    assign partial_sums_2[i][j] = partial_sums_1[i][j] //This keeps the bits in the same place if the height less then d, which comes from the Dadda Multiplier algorithm floor(3/2*d) where d is the size of the array, sequence goes 2,3,4,6,9,13,19,28,42,63
                end
                else begin: Reduction
                    for(z=0; z<abs(i-j); z++) begin //This makes sure that for any given column, does not preform more row reduction than necessary, in this case, 21
                    if (k == 0 || k % 2 == 1) begin //This makes sure if its the starter column or the column is odd, it will use a full adder. This makes sure that it switches off between full adders and half adders
                        Full_Adder fa_inst (
                            .A(A_input[i]), 
                            .B(B_input[i+1]), 
                            .Cin(Cin_input[k]), 
                            .Result(Result_output[k]), 
                            .Cout(Cout_output[k])
                        );
                        k=k+1;
                    end 
                    else if ( k % 2 == 0) begin
                        Half_Adder ha_inst (
                            .A(A_input[i]), 
                            .B(B_input[i+1]), 
                            .Result(Result_output[k]), 
                            .Cout(Cout_output[k])
                        );
                        k=k+1;
                    end
                end
            end
            end
    endgenerate
//Instantiate Full Adder
Full_Adder FA0(.A(partial_sums_1[i][j]), B(partial_sums_1[i+1][j]), .Cin(), .Result(partial_result), .Cout(partial_carry));

//Instantiate Half Adder
Half_Adder HA0(.A(partial_sums_1[i][j]), .B(partial_sums_1[i+1][j]), .Result(partial_result), .Cout(partial_carry));




    // Assign output
    assign product = final_sum;

endmodule

