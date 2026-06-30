// maxpool_controller.v (Final)
module maxpool_controller (
    input  wire clk,
    input  wire rst,
    output reg load_en,     
    output reg output_en    
);

    localparam [1:0]
        S_LOAD    = 2'b00,
        S_COMPARE = 2'b01,
        S_OUTPUT  = 2'b10;

    reg [1:0] current_state, next_state;

    // 1. Next State Logic (Combinatorial)
    always @(*) begin
        // CRITICAL FIX: Ensure next_state is always defined.
        next_state = current_state; 
        
        case (current_state)
            S_LOAD:    next_state = S_COMPARE;
            S_COMPARE: next_state = S_OUTPUT;
            S_OUTPUT:  next_state = S_LOAD;
            default:   next_state = S_LOAD;
        endcase
    end

    // 2. State Register Logic (Sequential - Synchronous Reset)
    always @(posedge clk) begin 
        if (rst) begin
            current_state <= S_LOAD;
        end else begin
            current_state <= next_state;
        end
    end

    // 3. Output Logic (Combinatorial)
    always @(*) begin
        load_en   = 1'b0;
        output_en = 1'b0;

        case (current_state)
            S_LOAD:    load_en = 1'b1;
            S_OUTPUT:  output_en = 1'b1;
            default: ; // S_COMPARE and default has both outputs low
        endcase
    end

endmodule