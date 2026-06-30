// tb_maxpool.v (Final Robust Version)
`timescale 1ns/1ps

module tb_maxpool;

    // ... [Declarations, DUT Instantiation, Clock Generation remain the same] ...
    reg  clk;
    reg  rst;
    reg  [15:0] data_a_in;
    reg  [15:0] data_b_in;
    reg  [15:0] data_c_in;
    reg  [15:0] data_d_in;
    // File-input helpers
    integer infile;
    integer scan_status;
    real    in_a_real, in_b_real, in_c_real, in_d_real;
    integer fix_tmp;
    
    wire [7:0] max_result_out;
    wire output_valid;
    reg  [31:0] error_count = 0;
    integer test_case_num = 0;
    parameter CLK_PERIOD = 10;

    // Instantiate DUT
    maxpool u_maxpool (
        .clk              (clk),
        .rst              (rst),
        .data_a_in        (data_a_in),
        .data_b_in        (data_b_in),
        .data_c_in        (data_c_in),
        .data_d_in        (data_d_in),
        .max_result_out   (max_result_out),
        .output_valid     (output_valid)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    reg  [7:0] expected_max;
    initial begin
        // --- Initialization and Reset Sequence ---
        rst = 1'b0;
        data_a_in = 16'h0000; data_b_in = 16'h0000;
        data_c_in = 16'h0000; data_d_in = 16'h0000;
        
        $display("\n--- Starting Max-Pooling Testbench (Q8.8 to Integer) ---");

        // Synchronous Reset
        @(posedge clk) #1;
        rst = 1'b1;
        @(posedge clk) #1;
        rst = 1'b0;
        $display("Reset released.");

        // Attempt to open user-provided input file `input.txt` in the DUT folder.
        infile = $fopen("input.txt", "r");
        if (infile) begin
            $display("Reading test vectors from input.txt (format: a b c d as decimal/fraction per line)");
            test_case_num = 0;
            while (!$feof(infile)) begin
                scan_status = $fscanf(infile, "%f %f %f %f\n", in_a_real, in_b_real, in_c_real, in_d_real);

                // Only process lines that correctly scanned 4 values
                if (scan_status == 4) begin
                    // Convert real inputs to Q8.8 fixed-point (16-bit unsigned representation)
                            // Expect inputs in the 0..255 range; scale by 256 to form Q8.8
                            fix_tmp = $rtoi(in_a_real * 256.0);
                            // Clip to unsigned 16-bit range (0..65535) to avoid wrap-around
                            if (fix_tmp > 65535) begin
                                $display("  WARNING: input a=%0f clipped to max representable unsigned Q8.8", in_a_real);
                                fix_tmp = 65535;
                            end else if (fix_tmp < 0) begin
                                $display("  WARNING: input a=%0f clipped to min representable unsigned Q8.8", in_a_real);
                                fix_tmp = 0;
                            end
                            data_a_in = fix_tmp[15:0];

                        fix_tmp = $rtoi(in_b_real * 256.0);
                        if (fix_tmp > 65535) begin
                            $display("  WARNING: input b=%0f clipped to max representable unsigned Q8.8", in_b_real);
                            fix_tmp = 65535;
                        end else if (fix_tmp < 0) begin
                            $display("  WARNING: input b=%0f clipped to min representable unsigned Q8.8", in_b_real);
                            fix_tmp = 0;
                        end
                        data_b_in = fix_tmp[15:0];

                        fix_tmp = $rtoi(in_c_real * 256.0);
                        if (fix_tmp > 65535) begin
                            $display("  WARNING: input c=%0f clipped to max representable unsigned Q8.8", in_c_real);
                            fix_tmp = 65535;
                        end else if (fix_tmp < 0) begin
                            $display("  WARNING: input c=%0f clipped to min representable unsigned Q8.8", in_c_real);
                            fix_tmp = 0;
                        end
                        data_c_in = fix_tmp[15:0];

                        fix_tmp = $rtoi(in_d_real * 256.0);
                        if (fix_tmp > 65535) begin
                            $display("  WARNING: input d=%0f clipped to max representable unsigned Q8.8", in_d_real);
                            fix_tmp = 65535;
                        end else if (fix_tmp < 0) begin
                            $display("  WARNING: input d=%0f clipped to min representable unsigned Q8.8", in_d_real);
                            fix_tmp = 0;
                        end
                        data_d_in = fix_tmp[15:0];

                    test_case_num = test_case_num + 1;

                    // Apply three clock cycles for LOAD -> COMPARE -> OUTPUT
                    @(posedge clk);
                    @(posedge clk);
                    @(posedge clk);

                    // Sample and display the result
                    #1;
                    $display("Test %0d: a=%0f b=%0f c=%0f d=%0f => max_out=%0d (0x%h)",
                             test_case_num, in_a_real, in_b_real, in_c_real, in_d_real, max_result_out, max_result_out);
                end
            end
            $fclose(infile);
        end else begin
            // Fallback to existing built-in tests when input.txt not present

            // --- Test Case 1: Positive Values (Inputs: 3, 7, 2, 5) ---
            test_case_num = test_case_num + 1;
            expected_max = 8'h07; 
            
            $display("\n--- Test Case %0d: Positive Values (Inputs: 3, 7, 2, 5) ---", test_case_num);
            // Inputs applied while FSM is in S_LOAD (after reset)
            data_a_in = 16'h0300; 
            data_b_in = 16'h0700; 
            data_c_in = 16'h0200; 
            data_d_in = 16'h0500; 

            @(posedge clk);
            @(posedge clk);
            @(posedge clk);

            // Read the registered output inside the task (avoid pass-by-value timing)
            check_result(expected_max, error_count, test_case_num);

            // --- Test Case 2: High Unsigned Values (Expected Max: 255) ---
            test_case_num = test_case_num + 1;
            expected_max = 8'hFF; // 255
            
            $display("\n--- Test Case %0d: High Unsigned Values (Inputs: 250, 200, 255, 240) ---", test_case_num);
            // Inputs applied while FSM is in S_LOAD (from end of last test)
            data_a_in = 16'hFA00; // 250.0 -> 0xFA00
            data_b_in = 16'hC800; // 200.0 -> 0xC800
            data_c_in = 16'hFF00; // 255.0 -> 0xFF00
            data_d_in = 16'hF000; // 240.0 -> 0xF000

            @(posedge clk); // Cycle 1
            @(posedge clk); // Cycle 2
            @(posedge clk); // Cycle 3

            check_result(expected_max, error_count, test_case_num);


            // --- Test Case 3: Mixed/Fractional (Expected Max: 6) ---
            test_case_num = test_case_num + 1;
            expected_max = 8'h06; // 6
            
            $display("\n--- Test Case %0d: Mixed/Fractional (Inputs: 3.5, 1.5, 6.0, 1.0) ---", test_case_num);
            data_a_in = 16'h0380; 
            data_b_in = 16'h0180;
            data_c_in = 16'h0600; 
            data_d_in = 16'h0100;

            @(posedge clk); // Cycle 1
            @(posedge clk); // Cycle 2
            @(posedge clk); // Cycle 3

            check_result(expected_max, error_count, test_case_num);

        end

        // End simulation summary
        $display("\n--- Simulation Finished ---");
        if (error_count == 0)
            $display("All %0d test cases passed!", test_case_num);
        else
            $display("Total Errors: %0d out of %0d tests.", error_count, test_case_num);

        $finish;
    end
    // 5. Task to check the result (Simplified, Samples after the output register is updated)
    task check_result;
        // Read the DUT output directly inside the task after waiting a clock edge.
        input [7:0] expected_out;
        inout [31:0] error_count;
        input integer case_num;

        begin
            // Sample the output shortly after the caller has completed the 3-cycle sequence.
            // The testbench advances the clock the required number of cycles before calling
            // this task, so a small inertial delay is sufficient to sample the registered output.
            #1;

            if (max_result_out === expected_out) begin
                $display("  PASS: Output=%0d (0x%h), Expected=%0d (0x%h)", max_result_out, max_result_out, expected_out, expected_out);
            end else begin
                $display("  **** FAIL ****: Test %0d Value Error. Output=%0d (0x%h), Expected=%0d (0x%h)", case_num, max_result_out, max_result_out, expected_out, expected_out);
                error_count = error_count + 1;
            end
        end
    endtask

endmodule