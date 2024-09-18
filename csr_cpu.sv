module cpu_csr (
    // AXI Clock and Reset
    input  wire          s_aclk,       // AXI clock signal
    input  wire          s_aresetn,    // AXI reset signal (active-low)
    
    // AXI Slave Read Address Channel
    input  wire [4:0]    s_axi_araddr,  // Read address (5 bits)
    input  wire [1:0]    s_axi_arburst, // Burst type
    input  wire [4:0]    s_axi_arid,    // Transaction ID (5 bits)
    input  wire [7:0]    s_axi_arlen,   // Burst length
    output reg           s_axi_arready, // Read address ready
    input  wire [2:0]    s_axi_arsize,  // Burst size
    input  wire          s_axi_arvalid, // Read address valid
    
    // AXI Slave Write Address Channel
    input  wire [4:0]    s_axi_awaddr,  // Write address (5 bits)
    input  wire [1:0]    s_axi_awburst, // Burst type
    input  wire [4:0]    s_axi_awid,    // Write transaction ID (5 bits)
    input  wire [7:0]    s_axi_awlen,   // Burst length
    output reg           s_axi_awready, // Write address ready
    input  wire [2:0]    s_axi_awsize,  // Burst size
    input  wire          s_axi_awvalid, // Write address valid
    
    // AXI Slave Write Response Channel
    output reg [4:0]     s_axi_bid,     // Write response transaction ID (5 bits)
    input  wire          s_axi_bready,  // Write response ready
    output reg [1:0]     s_axi_bresp,   // Write response
    output reg           s_axi_bvalid,  // Write response valid
    
    // AXI Slave Read Data Channel
    output reg [31:0]    s_axi_rdata,   // Read data
    output reg [4:0]     s_axi_rid,     // Read transaction ID (5 bits)
    output reg           s_axi_rlast,   // Read last
    input  wire          s_axi_rready,  // Read ready
    output reg [1:0]     s_axi_rresp,   // Read response
    output reg           s_axi_rvalid,  // Read valid
    
    // AXI Slave Write Data Channel
    input  wire [31:0]   s_axi_wdata,   // Write data
    input  wire          s_axi_wlast,   // Write last
    output reg           s_axi_wready,  // Write data ready
    input  wire [3:0]    s_axi_wstrb,   // Write strobes
    input  wire          s_axi_wvalid,  // Write valid
    
    // Optional busy signals
    output wire          rsta_busy,
    output wire          rstb_busy
);
    // Internal register array
    reg [31:0] regs [31:0];
    
    // Reset busy signals
    assign rsta_busy = 1'b0;
    assign rstb_busy = 1'b0;
    
    // Write address and data valid flags
    reg aw_valid;
    reg [4:0] awaddr_reg;
    reg [4:0] awid_reg;
    
    reg w_valid;
    reg [31:0] wdata_reg;
    reg [3:0] wstrb_reg;
    
    // Write response signals
    reg write_resp_pending;
    
    // Read address valid flags
    reg ar_valid;
    reg [4:0] araddr_reg;
    reg [4:0] arid_reg;
    
    // Read data signals
    reg read_data_pending;
    
    integer i;
    
    initial begin
        // Initialize ready and valid signals
        s_axi_awready = 1'b0;
        s_axi_wready = 1'b0;
        s_axi_bvalid = 1'b0;
        s_axi_bid = 5'd0;
        s_axi_bresp = 2'b00;
        
        s_axi_arready = 1'b0;
        s_axi_rvalid = 1'b0;
        s_axi_rdata = 32'd0;
        s_axi_rid = 5'd0;
        s_axi_rlast = 1'b0;
        s_axi_rresp = 2'b00;
        
        // Initialize registers
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'd0;
        end
    end
    
    // AXI Write Address Channel
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_awready <= 1'b0;
            aw_valid <= 1'b0;
            awaddr_reg <= 5'd0;
            awid_reg <= 5'd0;
        end else begin
            if (!s_axi_awready && s_axi_awvalid) begin
                // Accept write address
                s_axi_awready <= 1'b1;
                awaddr_reg <= s_axi_awaddr;
                awid_reg <= s_axi_awid;
                aw_valid <= 1'b1;
            end else begin
                s_axi_awready <= 1'b0;
            end
        end
    end
    
    // AXI Write Data Channel
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_wready <= 1'b0;
            w_valid <= 1'b0;
            wdata_reg <= 32'd0;
            wstrb_reg <= 4'd0;
        end else begin
            if (!s_axi_wready && s_axi_wvalid) begin
                // Accept write data
                s_axi_wready <= 1'b1;
                wdata_reg <= s_axi_wdata;
                wstrb_reg <= s_axi_wstrb;
                w_valid <= 1'b1;
            end else begin
                s_axi_wready <= 1'b0;
            end
        end
    end
    
    // Perform write when both address and data are valid
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            write_resp_pending <= 1'b0;
            s_axi_bvalid <= 1'b0;
        end else begin
            if (aw_valid && w_valid && !write_resp_pending) begin
                // Perform write
                if (awaddr_reg < 32) begin
                    // Apply write strobes
                    integer i_byte;
                    for (i_byte = 0; i_byte < 4; i_byte = i_byte + 1) begin
                        if (wstrb_reg[i_byte]) begin
                            regs[awaddr_reg][8*i_byte + 7 -: 8] <= wdata_reg[8*i_byte + 7 -: 8];
                        end
                    end
                end
                // Prepare to send write response
                s_axi_bvalid <= 1'b1;
                s_axi_bid <= awid_reg;
                s_axi_bresp <= 2'b00; // OKAY
                write_resp_pending <= 1'b1;
            end else if (s_axi_bvalid && s_axi_bready) begin
                // Write response accepted
                s_axi_bvalid <= 1'b0;
                write_resp_pending <= 1'b0;
            end
        end
    end
    
    // AXI Read Address Channel
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_arready <= 1'b0;
            ar_valid <= 1'b0;
            araddr_reg <= 5'd0;
            arid_reg <= 5'd0;
        end else begin
            if (!s_axi_arready && s_axi_arvalid) begin
                // Accept read address
                s_axi_arready <= 1'b1;
                araddr_reg <= s_axi_araddr;
                arid_reg <= s_axi_arid;
                ar_valid <= 1'b1;
            end else begin
                s_axi_arready <= 1'b0;
            end
        end
    end
    
    // AXI Read Data Channel
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata <= 32'd0;
            s_axi_rid <= 5'd0;
            s_axi_rlast <= 1'b0;
            s_axi_rresp <= 2'b00;
            read_data_pending <= 1'b0;
        end else begin
            if (ar_valid && !read_data_pending) begin
                // Prepare read data
                if (araddr_reg < 32) begin
                    s_axi_rdata <= regs[araddr_reg];
                    s_axi_rresp <= 2'b00; // OKAY
                end else begin
                    s_axi_rdata <= 32'd0;
                    s_axi_rresp <= 2'b10; // SLVERR
                end
                s_axi_rid <= arid_reg;
                s_axi_rvalid <= 1'b1;
                s_axi_rlast <= 1'b1; // Single beat
                read_data_pending <= 1'b1;
            end else if (s_axi_rvalid && s_axi_rready) begin
                // Read data accepted
                s_axi_rvalid <= 1'b0;
                read_data_pending <= 1'b0;
            end
        end
    end
endmodule
