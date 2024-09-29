 `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2024 12:35:05 PM
// Design Name: 
// Module Name: mau_tb
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

module mau_tb();

    // Clock and reset signals
    logic clk;
    logic resetn;
    logic access_enable;
    logic read_enable;
    logic write_enable;
    logic [31:0] access_addr;
    logic [31:0] write_data;
    logic [31:0] read_data;
    logic data_valid;
    logic write_done;

    // AXI signals for read and write
    logic [31:0] s_axi_araddr;
    logic [31:0] s_axi_awaddr;
    logic [1:0]  s_axi_arburst;
    logic [1:0]  s_axi_awburst;
    logic [3:0]  s_axi_arid;
    logic [3:0]  s_axi_awid;
    logic [7:0]  s_axi_arlen;
    logic [7:0]  s_axi_awlen;
    logic        s_axi_arvalid;
    logic        s_axi_arready;
    logic [31:0] s_axi_rdata;
    logic        s_axi_rvalid;
    logic        s_axi_rready;
    logic        s_axi_awvalid;
    logic        s_axi_awready;
    logic [31:0] s_axi_wdata;
    logic        s_axi_wvalid;
    logic        s_axi_wready;
    logic        s_axi_bvalid;

    // DUT (Device Under Test) instantiation
    mau uut (
        .clk(clk),
        .resetn(resetn),
        .access_enable(access_enable),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .access_addr(access_addr),
        .write_data(write_data),
        .read_data(read_data),
        .data_valid(data_valid),
        .write_done(write_done),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_arid(s_axi_arid),
        .s_axi_awid(s_axi_awid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bvalid(s_axi_bvalid)
    );

    // Mock DCCM instantiation
    dccm_wrapper dccm (
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
        .s_axi_rready(s_axi_rready),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bvalid(s_axi_bvalid)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        resetn = 0;
        access_enable = 0;
        read_enable = 0;
        write_enable = 0;
        access_addr = 32'h00000000;
        write_data = 32'h00000000;
        s_axi_arready = 0;
        s_axi_rdata = 32'h00000000;
        s_axi_rvalid = 0;
        s_axi_awready = 0;
        s_axi_wready = 0;
        s_axi_bvalid = 0;

        // Apply reset
        $display("Applying reset...");
        #10 resetn = 1;
        $display("Reset deasserted.");

        // Start write operation test
        access_addr = 32'h00000004;
        write_data = 32'hCAFEBABE;
        access_enable = 1;
        write_enable = 1;
        $display("Starting write. Write address: %h, Write data: %h", access_addr, write_data);
        #10;

        // Simulate AXI write address handshake
        #20 s_axi_awready = 1;
        $display("AXI ready to accept write address.");
        #10 s_axi_awready = 0;
        $display("AXI write address accepted.");

        // Simulate AXI write data handshake
        #10 s_axi_wready = 1;
        $display("AXI ready to accept write data.");
        #10 s_axi_wready = 0;
        s_axi_bvalid = 1;
        $display("AXI write data accepted and response received.");
        #10 s_axi_bvalid = 0;

        // Check write completion
        #20;
        if (write_done) begin
            $display("Write operation successful! Data written: %h", write_data);
        end else begin
            $display("Write operation failed!");
        end

        // Start read operation test
        write_enable = 0;
        read_enable = 1;
        access_addr = 32'h00000004;
        $display("Starting read. Read address: %h", access_addr);
        #10;

        // Simulate AXI read address handshake
        #20 s_axi_arready = 1;
        $display("AXI ready to accept read address.");
        #10 s_axi_arready = 0;
        $display("AXI read address accepted.");

        // Simulate AXI data return
        #10 s_axi_rdata = 32'hCAFEBABE;
             s_axi_rvalid = 1;
        $display("AXI returned data: %h", s_axi_rdata);
        #10 s_axi_rvalid = 0;
        $display("AXI data transfer complete.");

        // Check read data received
        #20;
        if (read_data == 32'hCAFEBABE && data_valid) begin
            $display("Read operation successful! Data read: %h", read_data);
        end else begin
            $display("Read operation failed! Received: %h, data_valid: %b", read_data, data_valid);
        end

        // End of simulation
        #50;
        $display("Simulation complete.");
        $stop;
    end

endmodule