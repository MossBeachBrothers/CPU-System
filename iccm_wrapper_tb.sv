`timescale 1ns / 1ps

module iccm_wrapper_tb();

    // Testbench signals
    reg                       tb_aclk;
    reg                       tb_aresetn;

    reg [31:0]                tb_axi_araddr;
    reg [1:0]                 tb_axi_arburst;
    reg [3:0]                 tb_axi_arid;
    reg [7:0]                 tb_axi_arlen;
    wire                      tb_axi_arready;
    reg [2:0]                 tb_axi_arsize;
    reg                       tb_axi_arvalid;

    reg [31:0]                tb_axi_awaddr;
    reg [1:0]                 tb_axi_awburst;
    reg [3:0]                 tb_axi_awid;
    reg [7:0]                 tb_axi_awlen;
    wire                      tb_axi_awready;
    reg [2:0]                 tb_axi_awsize;
    reg                       tb_axi_awvalid;

    wire [3:0]                tb_axi_bid;
    reg                       tb_axi_bready;
    wire [1:0]                tb_axi_bresp;
    wire                      tb_axi_bvalid;

    wire [31:0]               tb_axi_rdata;
    wire [3:0]                tb_axi_rid;
    wire                      tb_axi_rlast;
    reg                       tb_axi_rready;
    wire [1:0]                tb_axi_rresp;
    wire                      tb_axi_rvalid;

    reg [31:0]                tb_axi_wdata;
    reg                       tb_axi_wlast;
    wire                      tb_axi_wready;
    reg [3:0]                 tb_axi_wstrb;
    reg                       tb_axi_wvalid;

    wire                      tb_rsta_busy;
    wire                      tb_rstb_busy;

    reg [31:0]                write_data;
    reg [31:0]                read_data;

    // Instantiate the design under test (DUT)
    iccm_wrapper dut (
        .s_aclk(tb_aclk),
        .s_aresetn(tb_aresetn),
        .s_axi_araddr(tb_axi_araddr),
        .s_axi_arburst(tb_axi_arburst),
        .s_axi_arid(tb_axi_arid),
        .s_axi_arlen(tb_axi_arlen),
        .s_axi_arready(tb_axi_arready),
        .s_axi_arsize(tb_axi_arsize),
        .s_axi_arvalid(tb_axi_arvalid),
        .s_axi_awaddr(tb_axi_awaddr),
        .s_axi_awburst(tb_axi_awburst),
        .s_axi_awid(tb_axi_awid),
        .s_axi_awlen(tb_axi_awlen),
        .s_axi_awready(tb_axi_awready),
        .s_axi_awsize(tb_axi_awsize),
        .s_axi_awvalid(tb_axi_awvalid),
        .s_axi_bid(tb_axi_bid),
        .s_axi_bready(tb_axi_bready),
        .s_axi_bresp(tb_axi_bresp),
        .s_axi_bvalid(tb_axi_bvalid),
        .s_axi_rdata(tb_axi_rdata),
        .s_axi_rid(tb_axi_rid),
        .s_axi_rlast(tb_axi_rlast),
        .s_axi_rready(tb_axi_rready),
        .s_axi_rresp(tb_axi_rresp),
        .s_axi_rvalid(tb_axi_rvalid),
        .s_axi_wdata(tb_axi_wdata),
        .s_axi_wlast(tb_axi_wlast),
        .s_axi_wready(tb_axi_wready),
        .s_axi_wstrb(tb_axi_wstrb),
        .s_axi_wvalid(tb_axi_wvalid),
        .rsta_busy(tb_rsta_busy),
        .rstb_busy(tb_rstb_busy)
    );

    // Clock generation
    always #5 tb_aclk = ~tb_aclk; // 100 MHz clock

    initial begin
        // Initialize signals
        tb_aclk = 0;
        tb_aresetn = 0;
        tb_axi_araddr = 32'd0;
        tb_axi_arburst = 2'b00;
        tb_axi_arid = 4'b0;
        tb_axi_arlen = 8'b0;
        tb_axi_arsize = 3'b010;
        tb_axi_arvalid = 0;

        tb_axi_awaddr = 32'd0;
        tb_axi_awburst = 2'b00;
        tb_axi_awid = 4'b0;
        tb_axi_awlen = 8'b0;
        tb_axi_awsize = 3'b010;
        tb_axi_awvalid = 0;

        tb_axi_bready = 0;
        tb_axi_rready = 0;

        tb_axi_wdata = 32'd0;
        tb_axi_wlast = 0;
        tb_axi_wstrb = 4'b1111;
        tb_axi_wvalid = 0;

        write_data = 32'hDEADBEEF; // Data to be written

        // Apply reset
        #20 tb_aresetn = 1;

        // Wait for reset to propagate
        #50;

        // Write operation
        tb_axi_awaddr = 32'h00000010;  // Example address
        tb_axi_awvalid = 1;
        tb_axi_awid = 4'b0001;
        tb_axi_awlen = 8'b00000001;  // 1 beat burst
        tb_axi_wdata = write_data;   // Write data
        tb_axi_wvalid = 1;
        tb_axi_wlast = 1;
        tb_axi_bready = 1;

        // Wait for write transaction to complete
        wait(tb_axi_awready && tb_axi_wready);
        #20;

        // Clear signals after transaction
        tb_axi_awvalid = 0;
        tb_axi_wvalid = 0;
        tb_axi_wlast = 0;

        // Read operation
        tb_axi_araddr = 32'h00000010;  // Same address as the write
        tb_axi_arvalid = 1;
        tb_axi_arid = 4'b0001;
        tb_axi_arlen = 8'b00000001;  // 1 beat burst
        tb_axi_rready = 1;

        // Wait for read transaction to complete
        wait(tb_axi_arready);
        wait(tb_axi_rvalid && tb_axi_rlast);
        #20;

        // Capture read data
        read_data = tb_axi_rdata;

        // Verify the read-back data
        if (read_data == write_data) begin
            $display("Test PASSED: Read data matches written data.");
        end else begin
            $display("Test FAILED: Read data (0x%h) does not match written data (0x%h).", read_data, write_data);
        end

        // Clear signals after transaction
        tb_axi_arvalid = 0;
        tb_axi_rready = 0;

        // Finish simulation
        #100;
        $finish;
    end

    // Dump waveforms for viewing in simulation
    initial begin
        $dumpfile("iccm_wrapper_tb.vcd");  // Value change dump file
        $dumpvars(0, iccm_wrapper_tb);     // Dump all variables in the testbench
    end

endmodule