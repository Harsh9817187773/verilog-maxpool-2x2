// maxpool.v - Top-Level 2x2 Max-Pooling Module
module maxpool (
    // System Ports
    input  wire clk,
    input  wire rst,

    // Data Input Ports (16-bit Q8.8)
    input  wire [15:0] data_a_in,
    input  wire [15:0] data_b_in,
    input  wire [15:0] data_c_in,
    input  wire [15:0] data_d_in,

    // Data Output Ports (8-bit Integer)
    output wire [7:0] max_result_out, 
    output wire       output_valid    
);

    wire load_enable;
    wire output_enable;

    // output_valid is asserted when the result is available
    assign output_valid = output_enable;

    // 1. Instantiate the FSM Controller
    maxpool_controller u_controller (
        .clk        (clk),
        .rst        (rst),
        .load_en    (load_enable),
        .output_en  (output_enable)
    );

    // 2. Instantiate the Datapath
    maxpool_datapath u_datapath (
        .clk           (clk),
        .rst           (rst),
        .data_a_in     (data_a_in),
        .data_b_in     (data_b_in),
        .data_c_in     (data_c_in),
        .data_d_in     (data_d_in),
        .load_en       (load_enable),
        .output_en     (output_enable),
        .y_out_reg_out (max_result_out) // 8-bit connection
    );

endmodule