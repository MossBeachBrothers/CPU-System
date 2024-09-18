module cpu_csr_tb;

    reg s_aclk;
    reg s_aresetn;

    // AXI Signals
    reg [4:0] s_axi_araddr;
    reg [1:0] s_axi_arburst;
    reg [4:0] s_axi_arid;
    reg [7:0] s_axi_arlen;
    wire s_axi_arready;
    reg [2:0] s_axi_arsize;
    reg s_axi_arvalid;

    reg [4:0] s_axi_awaddr;
    reg [1:0] s_axi_awburst;
    reg [4:0] s_axi_awid;
    reg [7:0] s_axi_awlen;
    wire s_axi_awready;
    reg [2:0] s_axi_awsize;
    reg s_axi_awvalid;

    wire [4:0] s_axi_bid;
    reg s_axi_bready;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;

    wire [31:0] s_axi_rdata;
    wire [4:0] s_axi_rid;
    wire s_axi_rlast;
    reg s_axi_rready;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;

    reg [31:0] s_axi_wdata;
    reg s_axi_wlast;
    wire s_axi_wready;
    reg [3:0] s_axi_wstrb;
    reg s_axi_wvalid;

    // Instantiate the DUT
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
        .s_axi_wvalid(s_axi_wvalid)
    );

    // Clock generation
    initial begin
        s_aclk = 0;
        forever #5 s_aclk = ~s_aclk; // 10 time units clock period
    end

    // Test sequence
    initial begin
        // Reset
        s_aresetn = 0;
        #10;
        s_aresetn = 1;

        // Write to register 0
        s_axi_awaddr = 5'd0;
        s_axi_awid = 5'd1;
        s_axi_awvalid = 1'b1;
        s_axi_wdata = 32'hDEADBEEF;
        s_axi_wstrb = 4'b1111; // Write all bytes
        s_axi_wvalid = 1'b1;
        s_axi_wlast = 1'b1;

        // Wait for the write address to be accepted
        wait(s_axi_awready);
        s_axi_awvalid = 1'b0;

        // Wait for the write data to be accepted
        wait(s_axi_wready);
        s_axi_wvalid = 1'b0;

        // Wait for the write response
        wait(s_axi_bvalid);
        s_axi_bready = 1'b1; // Indicate readiness to accept response
        #10; // Wait for a cycle
        s_axi_bready = 1'b0;

        // Read from register 0
        s_axi_araddr = 5'd0;
        s_axi_arid = 5'd1;
        s_axi_arvalid = 1'b1;

        // Wait for the read address to be accepted
        wait(s_axi_arready);
        s_axi_arvalid = 1'b0;

        // Wait for the read data to be valid
        wait(s_axi_rvalid);
        s_axi_rready = 1'b1; // Indicate readiness to accept read data
        #10; // Wait for a cycle
        s_axi_rready = 1'b0;

        // Check read data
        if (s_axi_rdata !== 32'hDEADBEEF) begin
            $display("Error: Read data mismatch: expected 0xDEADBEEF, got 0x%0h", s_axi_rdata);
        end else begin
            $display("Read data matches expected value: 0x%0h", s_axi_rdata);
        end

        // Finish simulation
        #10;
        $finish;
    end
endmodule
