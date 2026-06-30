// cmp2.v - 2-Input Comparator Unit
module cmp2 (
    // Inputs (Q16.8 fixed-point internally; 24 bits total)
        input  wire [15:0] a_in,    // Fixed-point Q8.8 input A (16 bits)
        input  wire [15:0] b_in,    // Fixed-point Q8.8 input B (16 bits)

    // Output
        output reg  [15:0] max_out  // Fixed-point Q8.8 output: max(A, B)
);

    // Always block to perform the comparison logic
    // We use a combinatorial 'always @(*)' block since the output is
    // directly derived from the inputs without a clock.
    always @(*) begin
        // Perform an unsigned comparison to find the maximum value.
        // Inputs are treated as unsigned (0..255 range supported in
        // the typical 8-bit integer input case or as unsigned fixed-point
        // representation). Avoid $signed() so values 0..255 are compared
        // as expected.
        if (a_in > b_in) begin
            max_out = a_in;
        end else begin
            max_out = b_in;
        end
    end

endmodule