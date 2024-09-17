module start_sequence (
    input logic clk,              // Clock signal
    input logic hard_reset,          // Active-low reset signal
    input logic pll_lock, //indicates whether pll is locked 
    input logic cpu_enabled,    // Output to indicate CPU is enabled
    output logic pll_enable,
    output logic cpu_enable,
    output logic cpu_reset
);

    logic [4:0] cycle_count;
    logic [4:0] duration = 3'b101;
    logic release_resets;
    

    typedef enum logic [3:0] {
        IDLE        = 4'b0000,
        ENABLE_PLL  = 4'b0001,
        RELEASE_RESETS = 4'b0100,
        ENABLE_CPU  = 4'b0010,
        RUN         = 4'b0011
    } state_t;

    (* mark_debug = "true" *) state_t current_state, next_state;
    
    // Combinatorial logic for state transition
    always_comb begin
        case (current_state)
            IDLE: begin
                next_state = ENABLE_PLL;
                release_resets = 1'b0;
            end
            ENABLE_PLL: begin
                if (pll_lock) begin
                    next_state = RELEASE_RESETS;
                end else begin 
                    next_state = ENABLE_PLL;
                end 
            end             
            RELEASE_RESETS: begin
                next_state = ENABLE_CPU;
                release_resets = 1'b1;
            end 
            ENABLE_CPU: begin
                if (cpu_enabled) begin 
                    next_state = RUN;
                end else begin 
                    next_state = ENABLE_CPU;
                end  
                
            end
            RUN: begin 
                // Define transition from RUN if needed
                next_state = RUN; // or stay in RUN based on your requirements
            end
            default: next_state = IDLE;
        endcase
    end


    // Output logic based on current state
    always_ff @(posedge clk) begin
        if (hard_reset) begin
            current_state <= IDLE;
            cycle_count <= 3'b000;
        end else begin
            if (cycle_count == duration) begin // After 5 clock cycles
                current_state <= next_state;
                cycle_count <= 3'b000;
            end else begin
                // Stay in the current state, just increment the counter
                cycle_count <= cycle_count + 1;
            end
        end
    end
    
    assign pll_enable = (current_state == ENABLE_PLL);
    assign cpu_reset = (!release_resets);
    assign cpu_enable = (current_state == ENABLE_CPU);

endmodule
