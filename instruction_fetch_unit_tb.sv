`timescale 1ns / 1ps

module instruction_fetch_unit_tb();

    // Clock and reset signals
    logic clk;
    logic resetn;
    logic fetch_enable;
    logic [31:0] fetch_addr;
    logic [31:0] instruction;
    logic instr_valid;

    // AXI signals
    logic [31:0] s_axi_araddr;
    logic [1:0]  s_axi_arburst;
    logic [3:0]  s_axi_arid;
    logic [7:0]  s_axi_arlen;
    logic        s_axi_arvalid;
    logic        s_axi_arready;
    logic [31:0] s_axi_rdata;
    logic        s_axi_rvalid;
    logic        s_axi_rready;

    // DUT (Device Under Test) instantiation
    instruction_fetch_unit uut (
        .clk(clk),
        .resetn(resetn),
        .fetch_enable(fetch_enable),
        .fetch_addr(fetch_addr),
        .instruction(instruction),
        .instr_valid(instr_valid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );

    // Mock ICCM instantiation
    iccm_wrapper iccm (
        .s_aclk(clk),
        .s_aresetn(resetn),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arready(s_axi_arready),
        .s_axi_arsize(3'b010), // 4-byte burst
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        resetn = 0;
        fetch_enable = 0;
        fetch_addr = 32'h00000000;
        s_axi_arready = 0;
        s_axi_rdata = 32'h00000000;
        s_axi_rvalid = 0;

        // Apply reset
        $display("Applying reset...");
        #10 resetn = 1;
        $display("Reset deasserted.");

        // Start fetch instruction test
        fetch_addr = 32'h00000004;
        fetch_enable = 1;
        $display("Starting fetch. Fetch address: %h", fetch_addr);
        #10;

        // Simulate AXI handshakes
        #20 s_axi_arready = 1;
        $display("AXI ready to accept address.");
        #10 s_axi_arready = 0;
        $display("AXI address accepted.");

        // Simulate AXI data return
        #10 s_axi_rdata = 32'hDEADBEEF;
             s_axi_rvalid = 1;
        $display("AXI returned data: %h", s_axi_rdata);
        #10 s_axi_rvalid = 0;
        $display("AXI data transfer complete.");

        // Check instruction received
        #20;
        if (instruction == 32'hDEADBEEF && instr_valid) begin
            $display("Instruction fetch successful! Instruction: %h", instruction);
        end else begin
            $display("Instruction fetch failed! Received: %h, instr_valid: %b", instruction, instr_valid);
        end

        // End of simulation
        #50;
        $display("Simulation complete.");
        $stop;
    end

endmodule