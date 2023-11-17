//This is a Dadda Multiplier with 64-bit inputs and 128-bit output.

module dadda_multiplier (
    input [63:0] multiplicand,
    input [63:0] multiplier,
    output [127:0] product
);

    wire [63:0] partial_products [126:0];
    wire [63:0] partial_products_new [126:0];
    wire [127:0] partial_sums [0:31];
    wire [127:0] final_sum;

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

//Instantiate Full Adder
Full_Adder FA0(.A(), B(), .Cin(), .Result(), .Cout());

//Instantiate Half Adder
Half_Adder HA0(.A(), .B(), .Result(), .Cout());

//Align partial products 



    // Assign output
    assign product = final_sum;

endmodule

