    `timescale 1ns / 1ps

    module dccm_wrapper (
            // AXI Clock and Reset
            input  wire                       s_aclk,       // AXI clock signal
            input  wire                       s_aresetn,    // AXI reset signal (active-low)

            // AXI Slave Read Address Channel
            input  wire [31:0]                s_axi_araddr,  // Read address
            input  wire [1:0]                 s_axi_arburst, // Burst type
            input  wire [3:0]                 s_axi_arid,    // Transaction ID
            input  wire [7:0]                 s_axi_arlen,   // Burst length
            output wire                       s_axi_arready, // Read address ready
            input  wire [2:0]                 s_axi_arsize,  // Burst size
            input  wire                       s_axi_arvalid, // Read address valid

            // AXI Slave Write Address Channel
            input  wire [31:0]                s_axi_awaddr,  // Write address
            input  wire [1:0]                 s_axi_awburst, // Burst type
            input  wire [3:0]                 s_axi_awid,    // Write transaction ID
            input  wire [7:0]                 s_axi_awlen,   // Burst length
            output wire                       s_axi_awready, // Write address ready
            input  wire [2:0]                 s_axi_awsize,  // Burst size
            input  wire                       s_axi_awvalid, // Write address valid

            // AXI Slave Write Response Channel
            output wire [3:0]                 s_axi_bid,     // Write response transaction ID
            input  wire                       s_axi_bready,  // Write response ready
            output wire [1:0]                 s_axi_bresp,   // Write response
            output wire                       s_axi_bvalid,  // Write response valid

            // AXI Slave Read Data Channel
            output wire [31:0]                s_axi_rdata,   // Read data
            output wire [3:0]                 s_axi_rid,     // Read transaction ID
            output wire                       s_axi_rlast,   // Read last
            input  wire                       s_axi_rready,  // Read ready
            output wire [1:0]                 s_axi_rresp,   // Read response
            output wire                       s_axi_rvalid,  // Read valid

            // AXI Slave Write Data Channel
            input  wire [31:0]                s_axi_wdata,   // Write data
            input  wire                       s_axi_wlast,   // Write last
            output wire                       s_axi_wready,  // Write data ready
            input  wire [3:0]                 s_axi_wstrb,   // Write strobes
            input  wire                       s_axi_wvalid,  // Write valid

            // Optional busy signals (rsta_busy, rstb_busy)
            output wire                       rsta_busy,
            output wire                       rstb_busy
    );

        // Instantiate the Block Memory Generator IP core
        blk_mem_gen_1 blk_mem_inst (
            // AXI Interface
            .s_aclk        (s_aclk),
            .s_aresetn     (s_aresetn),
            
            // Read Address Channel
            .s_axi_araddr  (s_axi_araddr),
            .s_axi_arburst (s_axi_arburst),
            .s_axi_arid    (s_axi_arid),
            .s_axi_arlen   (s_axi_arlen),
            .s_axi_arready (s_axi_arready),
            .s_axi_arsize  (s_axi_arsize),
            .s_axi_arvalid (s_axi_arvalid),
            
            // Write Address Channel
            .s_axi_awaddr  (s_axi_awaddr),
            .s_axi_awburst (s_axi_awburst),
            .s_axi_awid    (s_axi_awid),
            .s_axi_awlen   (s_axi_awlen),
            .s_axi_awready (s_axi_awready),
            .s_axi_awsize  (s_axi_awsize),
            .s_axi_awvalid (s_axi_awvalid),

            // Write Response Channel
            .s_axi_bid     (s_axi_bid),
            .s_axi_bready  (s_axi_bready),
            .s_axi_bresp   (s_axi_bresp),
            .s_axi_bvalid  (s_axi_bvalid),
            
            // Read Data Channel
            .s_axi_rdata   (s_axi_rdata),
            .s_axi_rid     (s_axi_rid),
            .s_axi_rlast   (s_axi_rlast),
            .s_axi_rready  (s_axi_rready),
            .s_axi_rresp   (s_axi_rresp),
            .s_axi_rvalid  (s_axi_rvalid),
            
            // Write Data Channel
            .s_axi_wdata   (s_axi_wdata),
            .s_axi_wlast   (s_axi_wlast),
            .s_axi_wready  (s_axi_wready),
            .s_axi_wstrb   (s_axi_wstrb),
            .s_axi_wvalid  (s_axi_wvalid),
            
            // Busy Signals
            .rsta_busy     (rsta_busy),
            .rstb_busy     (rstb_busy)
        );

    endmodule
