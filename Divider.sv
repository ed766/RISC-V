//This is a Divider that takes in 2 64 bit numbers and outputs the Quotient and Remainder
module Divider #(
    parameter WIDTH = 64  // Define the width of the operands
)(
    input logic Start,            // Start signal for division
    input logic [WIDTH-1:0] Dividend, // Dividend
    input logic [WIDTH-1:0] Divisor,  // Divisor
    output logic [WIDTH-1:0] Quotient, // Quotient
    output logic [WIDTH-1:0] Remainder // Remainder
);

    // Internal signals
    logic [WIDTH-1:0] reg_remainder, reg_quotient;
    logic [WIDTH:0] reg_divisor; // Extended size for subtraction
    logic [WIDTH-1:0] reg_dividend;
    logic [5:0] count; // Counter for the number of iterations
    logic clk;
typedef enum logic [1:0] {
    IDLE,   // State where the divider is idle and waiting for 'Start' signal
    DIVIDE, // Active state where the division process is taking place
    DONE    // State to indicate the division process is complete
} state_t;


    state_t state, next_state;

    // Sequential logic for state transitions and counter
    always_ff @(posedge clk) begin
            state <= next_state;
            if (Start) begin
                count <= WIDTH; // Initialize the counter
            end else if (state == DIVIDE) begin
                count <= count - 1; // Count down with each division step
            end
        end

    // Combinational logic for state machine transitions
    always_comb begin
        next_state = state; // Default to stay in current state
        case (state)
            IDLE: if (Start) next_state = DIVIDE;
            DIVIDE: if (count == 0) next_state = DONE;
            DONE: if (!Start) next_state = IDLE;
        endcase
    end

    // Division logic
    always_ff @(posedge clk) begin
        if (state == IDLE && Start) begin
            // Initialization
            reg_dividend <= Dividend;
            reg_divisor <= {1'b0, Divisor}; // Align Divisor size with Remainder
            reg_quotient <= 0;
            reg_remainder <= 0;
        end else if (state == DIVIDE) begin
            // Perform the division algorithm
            reg_remainder <= (reg_remainder << 1) | reg_dividend[WIDTH-1];
            reg_dividend <= reg_dividend << 1; // Shift left Dividend
            // Attempt to subtract Divisor from Remainder
            if (reg_remainder >= reg_divisor) begin
                reg_remainder <= reg_remainder - reg_divisor;
                reg_quotient <= (reg_quotient << 1) | 1'b1;
            end else begin
                reg_quotient <= reg_quotient << 1;
            end
        end
        if (state == DONE) begin
            // Output the results
            Quotient <= reg_quotient;
            Remainder <= reg_remainder;
        end
    end

endmodule
