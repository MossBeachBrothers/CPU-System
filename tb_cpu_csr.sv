module tb_cpu_csr;
    // Testbench signals
    reg         clk;
    reg         rstn;
    
    // AXI signals
    reg  [4:0]  s_axi_awaddr;
    reg  [4:0]  s_axi_araddr;
    reg  [1:0]  s_axi_awburst;
    reg  [1:0]  s_axi_arburst;
    reg  [4:0]  s_axi_awid;
    reg  [4:0]  s_axi_arid;
    reg  [7:0]  s_axi_awlen;
    reg  [7:0]  s_axi_arlen;
    reg  [2:0]  s_axi_awsize;
    reg  [2:0]  s_axi_arsize;
    reg         s_axi_awvalid;
    reg         s_axi_arvalid;
    
    wire        s_axi_awready;
    wire        s_axi_arready;
    wire [4:0] s_axi_bid;
    wire        s_axi_bvalid;
    wire [1:0] s_axi_bresp;
    
    wire [31:0] s_axi_rdata;
    wire        s_axi_rvalid;
    wire        s_axi_rlast;
    wire [4:0] s_axi_rid;
    wire [1:0] s_axi_rresp;
    
    reg  [31:0] s_axi_wdata;
    reg  [3:0]  s_axi_wstrb;
    reg         s_axi_wvalid;
    wire        s_axi_wready;
    
    cpu_csr uut (
        .s_aclk(clk),
        .s_aresetn(rstn),
        
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_awid(s_axi_awid),
        .s_axi_arid(s_axi_arid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_arvalid(s_axi_arvalid),
        
        .s_axi_awready(s_axi_awready),
        .s_axi_arready(s_axi_arready),
        .s_axi_bid(s_axi_bid),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bresp(s_axi_bresp),
        
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rid(s_axi_rid),
        .s_axi_rresp(s_axi_rresp),
        
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(1'b1),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Reset generation
    initial begin
        rstn = 0;
        #20;
        rstn = 1;
    end
    
    // Test sequence
    initial begin
        // Write to registers
        s_axi_awaddr = 5'd0; 
        s_axi_wdata = 32'hDEADBEEF; 
        s_axi_wstrb = 4'b1111; 
        s_axi_awvalid = 1'b1; 
        s_axi_wvalid = 1'b1;
        
        wait(s_axi_awready);
        wait(s_axi_wready);
        
        s_axi_awvalid = 1'b0; 
        s_axi_wvalid = 1'b0;

        // Read from registers
        s_axi_araddr = 5'd0; 
        s_axi_arvalid = 1'b1;

        wait(s_axi_arready);
        s_axi_arvalid = 1'b0;

        wait(s_axi_rvalid);
        
        // Check read data
        if (s_axi_rdata !== 32'hDEADBEEF) begin
            $display("Error: Read data mismatch.");
        end else begin
            $display("Read data matches expected value: 0x%0h", s_axi_rdata);
        end
        
        // Further testing...
        // Write and read other registers here...

        $stop; // End simulation
    end
endmodule
