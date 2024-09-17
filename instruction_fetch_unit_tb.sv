`timescale 1ns / 1ps

module instruction_fetch_unit_tb;

    // Clock and Reset Signals
    reg         s_aclk;
    reg         s_aresetn;

    // Instruction Fetch Unit Signals
    reg  [31:0] address;
    reg         fetch;
    wire [31:0] instruction;

    // AXI Master Interface Signals from Instruction Fetch Unit
    wire [31:0] m_axi_araddr;
    wire [1:0]  m_axi_arburst;
    wire [3:0]  m_axi_arid;
    wire [7:0]  m_axi_arlen;
    wire        m_axi_arvalid;
    wire [2:0]  m_axi_arsize;
    wire        m_axi_rready;

    wire        m_axi_arready;
    wire [31:0] m_axi_rdata;
    wire [3:0]  m_axi_rid;
    wire        m_axi_rlast;
    wire [1:0]  m_axi_rresp;
    wire        m_axi_rvalid;

    // AXI Slave Interface Signals to ICCM Wrapper for Write Transactions
    reg  [31:0] s_axi_awaddr;
    reg  [1:0]  s_axi_awburst;
    reg  [3:0]  s_axi_awid;
    reg  [7:0]  s_axi_awlen;
    reg         s_axi_awvalid;
    reg  [2:0]  s_axi_awsize;
    wire        s_axi_awready;

    reg  [31:0] s_axi_wdata;
    reg         s_axi_wlast;
    reg  [3:0]  s_axi_wstrb;
    reg         s_axi_wvalid;
    wire        s_axi_wready;

    wire [3:0]  s_axi_bid;
    reg         s_axi_bready;
    wire [1:0]  s_axi_bresp;
    wire        s_axi_bvalid;

    // Instantiate Instruction Fetch Unit
    instruction_fetch_unit ifu (
        .s_aclk        (s_aclk),
        .s_aresetn     (s_aresetn),
        .address       (address),
        .fetch         (fetch),
        .instruction   (instruction),

        // AXI Master Read Address Channel
        .m_axi_araddr  (m_axi_araddr),
        .m_axi_arburst (m_axi_arburst),
        .m_axi_arid    (m_axi_arid),
        .m_axi_arlen   (m_axi_arlen),
        .m_axi_arready (m_axi_arready),
        .m_axi_arsize  (m_axi_arsize),
        .m_axi_arvalid (m_axi_arvalid),

        // AXI Master Read Data Channel
        .m_axi_rdata   (m_axi_rdata),
        .m_axi_rid     (m_axi_rid),
        .m_axi_rlast   (m_axi_rlast),
        .m_axi_rready  (m_axi_rready),
        .m_axi_rresp   (m_axi_rresp),
        .m_axi_rvalid  (m_axi_rvalid)
    );

    // Instantiate ICCM Wrapper
    iccm_wrapper iccm (
        .s_aclk        (s_aclk),
        .s_aresetn     (s_aresetn),

        // AXI Slave Read Address Channel
        .s_axi_araddr  (m_axi_araddr),
        .s_axi_arburst (m_axi_arburst),
        .s_axi_arid    (m_axi_arid),
        .s_axi_arlen   (m_axi_arlen),
        .s_axi_arready (m_axi_arready),
        .s_axi_arsize  (m_axi_arsize),
        .s_axi_arvalid (m_axi_arvalid),

        // AXI Slave Read Data Channel
        .s_axi_rdata   (m_axi_rdata),
        .s_axi_rid     (m_axi_rid),
        .s_axi_rlast   (m_axi_rlast),
        .s_axi_rready  (m_axi_rready),
        .s_axi_rresp   (m_axi_rresp),
        .s_axi_rvalid  (m_axi_rvalid),

        // AXI Slave Write Address Channel
        .s_axi_awaddr  (s_axi_awaddr),
        .s_axi_awburst (s_axi_awburst),
        .s_axi_awid    (s_axi_awid),
        .s_axi_awlen   (s_axi_awlen),
        .s_axi_awready (s_axi_awready),
        .s_axi_awsize  (s_axi_awsize),
        .s_axi_awvalid (s_axi_awvalid),

        // AXI Slave Write Data Channel
        .s_axi_wdata   (s_axi_wdata),
        .s_axi_wlast   (s_axi_wlast),
        .s_axi_wready  (s_axi_wready),
        .s_axi_wstrb   (s_axi_wstrb),
        .s_axi_wvalid  (s_axi_wvalid),

        // AXI Slave Write Response Channel
        .s_axi_bid     (s_axi_bid),
        .s_axi_bready  (s_axi_bready),
        .s_axi_bresp   (s_axi_bresp),
        .s_axi_bvalid  (s_axi_bvalid),

        // Busy Signals
        .rsta_busy     (),
        .rstb_busy     ()
    );

    // Clock Generation
    initial begin
        s_aclk = 0;
        forever #5 s_aclk = ~s_aclk;  // 100MHz Clock
    end

    // Reset Generation
    initial begin
        s_aresetn = 0;
        #20;
        s_aresetn = 1;
    end

    // Test Sequence
    initial begin
        // Initialize signals
        fetch        = 0;
        address      = 32'h00000000;
        s_axi_awaddr = 32'd0;
        s_axi_awburst= 2'b01;
        s_axi_awid   = 4'd0;
        s_axi_awlen  = 8'd0;
        s_axi_awsize = 3'd2;
        s_axi_awvalid= 1'b0;
        s_axi_wdata  = 32'd0;
        s_axi_wlast  = 1'b0;
        s_axi_wstrb  = 4'hF;
        s_axi_wvalid = 1'b0;
        s_axi_bready = 1'b1;

        // Wait for reset de-assertion
        @(negedge s_aresetn);
        @(posedge s_aresetn);
        #10;

        // Write Dummy Data into ICCM
        axi_write(32'h00000000, 32'hDEADBEEF);  // Address 0x00000000
        axi_write(32'h00000004, 32'hCAFEBABE);  // Address 0x00000004
        axi_write(32'h00000008, 32'h12345678);  // Address 0x00000008

        // Fetch Instructions
        #20;
        fetch_instruction(32'h00000000);
        fetch_instruction(32'h00000004);
        fetch_instruction(32'h00000008);

        #100;
        $finish;
    end

    // Task to Perform AXI Write
    task axi_write(input [31:0] addr, input [31:0] data);
    begin
        // Write Address Channel
        @(posedge s_aclk);
        s_axi_awaddr  <= addr;
        s_axi_awvalid <= 1'b1;
        s_axi_awlen   <= 8'd0;   // Single beat
        s_axi_awsize  <= 3'd2;   // 4 bytes
        s_axi_awburst <= 2'b01;  // INCR burst

        // Write Data Channel
        s_axi_wdata   <= data;
        s_axi_wvalid  <= 1'b1;
        s_axi_wlast   <= 1'b1;
        s_axi_wstrb   <= 4'hF;   // All bytes valid

        // Wait for Write Address Handshake
        wait (s_axi_awready && s_axi_awvalid);
        @(posedge s_aclk);
        s_axi_awvalid <= 1'b0;

        // Wait for Write Data Handshake
        wait (s_axi_wready && s_axi_wvalid);
        @(posedge s_aclk);
        s_axi_wvalid <= 1'b0;
        s_axi_wlast  <= 1'b0;

        // Wait for Write Response
        wait (s_axi_bvalid);
        @(posedge s_aclk);
        s_axi_bready <= 1'b1;
        @(posedge s_aclk);
        s_axi_bready <= 1'b0;
    end
    endtask

    // Task to Fetch Instruction
    task fetch_instruction(input [31:0] addr);
    begin
        @(posedge s_aclk);
        address <= addr;
        fetch   <= 1'b1;
        @(posedge s_aclk);
        fetch   <= 1'b0;

        // Wait for Instruction to be Valid
        wait (ifu.state == ifu.IDLE);
        @(posedge s_aclk);
        $display("Fetched Instruction at Address 0x%08X: 0x%08X", addr, instruction);
    end
    endtask

endmodule
