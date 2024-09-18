`timescale 1ns / 1ps

module tb_cpu_csr;

    // Parameters
    parameter ADDR_WIDTH = 5;
    parameter DATA_WIDTH = 32;
    
    // Clock and reset
    reg s_aclk;
    reg s_aresetn;

    // AXI signals
    reg [ADDR_WIDTH-1:0] s_axi_araddr;
    reg [1:0] s_axi_arburst;
    reg [ADDR_WIDTH-1:0] s_axi_arid;
    reg [7:0] s_axi_arlen;
    wire s_axi_arready;
    reg [2:0] s_axi_arsize;
    reg s_axi_arvalid;

    reg [ADDR_WIDTH-1:0] s_axi_awaddr;
    reg [1:0] s_axi_awburst;
    reg [ADDR_WIDTH-1:0] s_axi_awid;
    reg [7:0] s_axi_awlen;
    wire s_axi_awready;
    reg [2:0] s_axi_awsize;
    reg s_axi_awvalid;

    wire [ADDR_WIDTH-1:0] s_axi_bid;
    reg s_axi_bready;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;

    wire [DATA_WIDTH-1:0] s_axi_rdata;
    wire [ADDR_WIDTH-1:0] s_axi_rid;
    wire s_axi_rlast;
    reg s_axi_rready;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;

    reg [DATA_WIDTH-1:0] s_axi_wdata;
    reg s_axi_wlast;
    wire s_axi_wready;
    reg [3:0] s_axi_wstrb;
    reg s_axi_wvalid;

    // Instantiate the cpu_csr module
    cpu_csr uut (
        .s_aclk(s_aclk),
        .s_aresetn(s_aresetn),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arready(s_axi_arready),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awready(s_axi_awready),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(s_axi_bid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(s_axi_rid),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .rsta_busy(),
        .rstb_busy()
    );

    // Clock generation
    initial begin
        s_aclk = 0;
        forever #5 s_aclk = ~s_aclk;
    end

    // Test procedure
    initial begin
        // Initialize signals
        s_aresetn = 0;
        s_axi_arvalid = 0;
        s_axi_awvalid = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_rready = 0;

        // Reset the DUT
        #15;
        s_aresetn = 1;

        // Test writes to multiple addresses
        for (int addr = 0; addr < 5; addr = addr + 1) begin
            write_data(addr, 32'hA5A5A5A5 + addr); // Write unique data
        end

        // Test reads from the same addresses
        for (int addr = 0; addr < 5; addr = addr + 1) begin
            read_data(addr, 32'hA5A5A5A5 + addr); // Read and check against expected data
        end

        // Finish the simulation
        #100;
        $finish;
    end

    // Write task
    task write_data(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            // Write Address
            s_axi_awaddr = addr;
            s_axi_awid = addr;
            s_axi_awvalid = 1;
            @(posedge s_aclk);
            while (!s_axi_awready) @(posedge s_aclk);
            s_axi_awvalid = 0;

            // Write Data
            s_axi_wdata = data;
            s_axi_wstrb = 4'b1111; // Write all bytes
            s_axi_wvalid = 1;
            s_axi_wlast = 1; // Last data
            @(posedge s_aclk);
            while (!s_axi_wready) @(posedge s_aclk);
            s_axi_wvalid = 0;

            // Read back response
            s_axi_bready = 1;
            @(posedge s_aclk);
            while (!s_axi_bvalid) @(posedge s_aclk);
            s_axi_bready = 0;
            $display("Wrote 0x%0h to address %0d, Response: %0d", data, addr, s_axi_bresp);
        end
    endtask

    // Read task
    task read_data(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] expected_data);
        reg [DATA_WIDTH-1:0] read_data;
        begin
            // Read Address
            s_axi_araddr = addr;
            s_axi_arid = addr;
            s_axi_arvalid = 1;
            @(posedge s_aclk);
            while (!s_axi_arready) @(posedge s_aclk);
            s_axi_arvalid = 0;

            // Read Data
            s_axi_rready = 1;
            @(posedge s_aclk);
            while (!s_axi_rvalid) @(posedge s_aclk);
            read_data = s_axi_rdata;
            s_axi_rready = 0;
            
            // Check if read data matches expected data
            if (read_data === expected_data) begin
                $display("PASS: Read 0x%0h from address %0d, matches expected data", read_data, addr);
            end else begin
                $display("FAIL: Read 0x%0h from address %0d, expected 0x%0h", read_data, addr, expected_data);
            end
            $display("Response: %0d", s_axi_rresp);
        end
    endtask

endmodule