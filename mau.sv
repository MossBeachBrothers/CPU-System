`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2024 12:31:57 PM
// Design Name: 
// Module Name: mau
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module mau (
    input  logic        clk,
    input  logic        resetn,
    input  logic        access_enable,      // Signal to initiate a read or write
    input  logic        read_enable,        // Enable signal for reading
    input  logic        write_enable,       // Enable signal for writing
    input  logic [31:0] access_addr,        // Address for read/write
    input  logic [31:0] write_data,         // Data to write to memory
    output logic [31:0] read_data,          // Data read from memory
    output logic        data_valid,         // Indicates valid data
    output logic        write_done,         // Indicates write completed

    // AXI interface to DCCM memory
    output logic [31:0] s_axi_araddr,
    output logic [31:0] s_axi_awaddr,
    output logic [1:0]  s_axi_arburst,
    output logic [1:0]  s_axi_awburst,
    output logic [3:0]  s_axi_arid,
    output logic [3:0]  s_axi_awid,
    output logic [7:0]  s_axi_arlen,
    output logic [7:0]  s_axi_awlen,
    output logic        s_axi_arvalid,
    output logic        s_axi_awvalid,
    output logic [31:0] s_axi_wdata,
    output logic        s_axi_wvalid,
    input  logic        s_axi_arready,
    input  logic        s_axi_awready,
    input  logic        s_axi_wready,
    input  logic [31:0] s_axi_rdata,
    input  logic        s_axi_rvalid,
    input  logic        s_axi_bvalid,
    output logic        s_axi_rready,
    output logic        s_axi_bready
);

    // Define state types
    typedef enum logic [2:0] {IDLE, READ, WAIT_READ, WRITE, WAIT_WRITE, DONE} state_t;
    state_t state, next_state;

    // AXI burst size configuration
    logic [2:0] s_axi_arsize = 3'b010; // Burst size: 4 bytes (32 bits)
    logic [2:0] s_axi_awsize = 3'b010; // Burst size: 4 bytes (32 bits)

    // Sequential logic for state transitions
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Output and AXI control logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            s_axi_arvalid <= 1'b0;
            s_axi_awvalid <= 1'b0;
            s_axi_wvalid  <= 1'b0;
            s_axi_rready  <= 1'b0;
            s_axi_bready  <= 1'b0;
            data_valid    <= 1'b0;
            write_done    <= 1'b0;
            read_data     <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (access_enable) begin
                        if (read_enable) begin
                            // Prepare for read transaction
                            s_axi_araddr  <= access_addr;
                            s_axi_arburst <= 2'b01;  // INCR burst type
                            s_axi_arid    <= 4'b0000; // Transaction ID
                            s_axi_arlen   <= 8'b00000000; // Single transfer
                            s_axi_arvalid <= 1'b1;
                            data_valid    <= 1'b0;
                        end else if (write_enable) begin
                            // Prepare for write transaction
                            s_axi_awaddr  <= access_addr;
                            s_axi_awburst <= 2'b01;  // INCR burst type
                            s_axi_awid    <= 4'b0000; // Transaction ID
                            s_axi_awlen   <= 8'b00000000; // Single transfer
                            s_axi_awvalid <= 1'b1;
                            s_axi_wdata   <= write_data;
                            s_axi_wvalid  <= 1'b1;
                            write_done    <= 1'b0;
                        end
                    end
                end
                READ: begin
                    if (s_axi_arready) begin
                        s_axi_arvalid <= 1'b0;
                        s_axi_rready  <= 1'b1;
                    end
                end
                WAIT_READ: begin
                    if (s_axi_rvalid) begin
                        read_data <= s_axi_rdata;
                        data_valid <= 1'b1;
                        s_axi_rready <= 1'b0;
                    end
                end
                WRITE: begin
                    if (s_axi_awready) begin
                        s_axi_awvalid <= 1'b0;
                        s_axi_wvalid  <= 1'b1;
                    end
                end
                WAIT_WRITE: begin
                    if (s_axi_wready) begin
                        s_axi_wvalid <= 1'b0;
                        s_axi_bready <= 1'b1;
                    end
                    if (s_axi_bvalid) begin
                        write_done <= 1'b1;
                        s_axi_bready <= 1'b0;
                    end
                end
                DONE: begin
                    // Remain in DONE state until access_enable is deasserted
                end
            endcase
        end
    end

    // Combinational logic for next state
    always_comb begin
        next_state = state;  // Default to current state
        case (state)
            IDLE: begin
                if (access_enable) begin
                    if (read_enable) 
                        next_state = READ;
                    else if (write_enable) 
                        next_state = WRITE;
                end
            end
            READ: if (s_axi_arready) next_state = WAIT_READ;
            WAIT_READ: if (s_axi_rvalid) next_state = DONE;
            WRITE: if (s_axi_awready) next_state = WAIT_WRITE;
            WAIT_WRITE: if (s_axi_wready && s_axi_bvalid) next_state = DONE;
            DONE: if (!access_enable) next_state = IDLE;
        endcase
    end

endmodule