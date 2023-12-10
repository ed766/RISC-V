//This is an Array Multiplier that takes 2 64 bit numbers and outputs the result as a 128 bit number
module Array_Multiplier(
    input signed [63:0] A,
    input signed [63:0] B,
    output reg signed [127:0] Result
);

    logic [63:0] Partial_products[63:0];  // 2D array to hold partial products
    logic [127:0] Partial_sum[63:0];
    logic [127:0] Sum;
    integer i, j, k;

    // Generate partial products
    always_comb begin
        for (i = 0; i < 64; i++) begin
            for (j = 0; j < 64; j++) begin
                Partial_products[i][j] = A[i] & B[j];
            end
            // Each partial product is shifted according to its bit position
            Partial_sum[i] = Partial_products[i] << i;
        end
    end

    // Sum the partial products
    always_comb begin
        Sum = 128'b0;
        for (k = 0; k < 64; k++) begin
            Sum = Sum + Partial_sum[k];
        end
        Result = Sum;
    end

endmodule
