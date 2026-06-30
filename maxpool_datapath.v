// maxpool_datapath.v - Datapath for 2x2 Max-Pooling (SYNCHRONOUS RESET & 8-bit Output)
module maxpool_datapath (
    input  wire clk,
    input  wire rst,
    input  wire [15:0] data_a_in,
    input  wire [15:0] data_b_in,
    input  wire [15:0] data_c_in,
    input  wire [15:0] data_d_in,
    input  wire load_en,
    input  wire output_en,
    output wire [7:0] y_out_reg_out // Output is 8 bits (Q8)
);

    // Internal Registers (Still 16-bit Q8.8 for internal comparison)
    reg [15:0] reg_a, reg_b, reg_c, reg_d; 
    reg [7:0] y_out_integer;               // 8-bit output register

    wire [15:0] max_from_tree;

    // 1. Input Register Logic (Synchronous Reset)
    always @(posedge clk) begin 
        if (rst) begin
            reg_a <= 16'h0000;
            reg_b <= 16'h0000;
            reg_c <= 16'h0000;
            reg_d <= 16'h0000;
        end else if (load_en) begin
            reg_a <= data_a_in;
            reg_b <= data_b_in;
            reg_c <= data_c_in;
            reg_d <= data_d_in;
        end
    end

    // 2. Comparator Tree Instantiation
    cmp_tree u_cmp_tree (
        .a_in    (reg_a),
        .b_in    (reg_b),
        .c_in    (reg_c),
        .d_in    (reg_d),
        .max_out (max_from_tree) // 16-bit Q8.8 result
    );

    // 3. Output Register Logic (Synchronous Reset & Output Shift)
    always @(posedge clk) begin 
        if (rst) begin
            y_out_integer <= 8'h00;
        end else if (output_en) begin
            // **CORRECT EXTRACTION** Extract the integer part [15:8] (Q8) from the Q8.8 result
            y_out_integer <= max_from_tree[15:8];
        end
    end

    assign y_out_reg_out = y_out_integer;

endmodule