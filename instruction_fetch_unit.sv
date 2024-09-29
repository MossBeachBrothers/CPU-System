`timescale 1ns / 1ps

module instruction_fetch_unit (
    input  logic        clk,
    input  logic        resetn,
    input  logic        fetch_enable,
    input  logic [31:0] fetch_addr,
    output logic [31:0] instruction,
    output logic        instr_valid,

    // AXI interface to ICCM memory
    output logic [31:0] s_axi_araddr,
    output logic [1:0]  s_axi_arburst,
    output logic [3:0]  s_axi_arid,
    output logic [7:0]  s_axi_arlen,
    output logic        s_axi_arvalid,
    input  logic        s_axi_arready,
    input  logic [31:0] s_axi_rdata,
    input  logic        s_axi_rvalid,
    output logic        s_axi_rready
);

    // Define state types
    typedef enum logic [1:0] {IDLE, FETCH, WAIT, DONE} state_t;
    state_t state, next_state;

    // AXI burst type configuration
    logic [2:0] s_axi_arsize = 3'b010; // Burst size: 4 bytes (32 bits)

    // Sequential logic for state transitions
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            state <= IDLE;
        else
            state <= next_state;  // State transitions based on combinational logic
    end

    // Output and AXI control logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            s_axi_arvalid <= 1'b0;
            s_axi_rready  <= 1'b0;
            instr_valid   <= 1'b0;
            instruction   <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (fetch_enable) begin
                        s_axi_araddr  <= fetch_addr;
                        s_axi_arburst <= 2'b01;  // INCR burst type
                        s_axi_arid    <= 4'b0000; // Transaction ID
                        s_axi_arlen   <= 8'b00000000; // Single transfer
                        s_axi_arvalid <= 1'b1;
                        instr_valid   <= 1'b0;
                    end
                end
                FETCH: begin
                    if (s_axi_arready) begin
                        s_axi_arvalid <= 1'b0;
                        s_axi_rready  <= 1'b1;
                    end
                end
                WAIT: begin
                    if (s_axi_rvalid) begin
                        instruction <= s_axi_rdata;
                        instr_valid <= 1'b1;
                        s_axi_rready <= 1'b0;
                    end
                end
                DONE: begin
                    // Do nothing in DONE state
                end
            endcase
        end
    end

    // Combinational block for next state logic
    always_comb begin
        next_state = state;  // Default to current state
        case (state)
            IDLE:   if (fetch_enable) next_state = FETCH;
            FETCH:  if (s_axi_arready) next_state = WAIT;
            WAIT:   if (s_axi_rvalid) next_state = DONE;
            DONE:   if (!fetch_enable) next_state = IDLE;
        endcase
    end

endmodule