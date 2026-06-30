// cmp_tree.v - 4-Input Comparator Tree Module (Q8.8)
module cmp_tree (
    // Inputs: Four fixed-point Q8.8 values
    input  wire [15:0] a_in,
    input  wire [15:0] b_in,
    input  wire [15:0] c_in,
    input  wire [15:0] d_in,

    // Output: The maximum of the four inputs
    output wire [15:0] max_out
);

    // Internal wires to hold the intermediate results from Stage 1
    wire [15:0] stage1_max_ab; // max(a_in, b_in)
    wire [15:0] stage1_max_cd; // max(c_in, d_in)

    // Stage 1: Two parallel 2-input comparators
    // ----------------------------------------
    // Instance 1: Compares A and B
    cmp2 u1_cmp_ab (
        .a_in  (a_in),
        .b_in  (b_in),
        .max_out (stage1_max_ab) // Result of max(A, B)
    );

    // Instance 2: Compares C and D
    cmp2 u2_cmp_cd (
        .a_in  (c_in),
        .b_in  (d_in),
        .max_out (stage1_max_cd) // Result of max(C, D)
    );

    // Stage 2: Final 2-input comparator
    // ---------------------------------
    // Instance 3: Compares the two intermediate maximums
    cmp2 u3_cmp_final (
        .a_in  (stage1_max_ab), // Input A is max(A, B)
        .b_in  (stage1_max_cd), // Input B is max(C, D)
        .max_out (max_out)       // Final output: max(A, B, C, D)
    );
endmodule