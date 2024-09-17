module flash_memory_wrapper (
    // System Signals
    input wire s_axi_aclk,
    input wire s_axi_aresetn,
    input wire rdclk,

    // AXI Slave Interface Signals
    input wire [31:0] s_axi_mem_araddr,
    input wire [1:0] s_axi_mem_arburst,
    input wire [3:0] s_axi_mem_arcache,
    input wire [3:0] s_axi_mem_arid,
    input wire [7:0] s_axi_mem_arlen,
    input wire s_axi_mem_arlock,
    input wire [2:0] s_axi_mem_arprot,
    input wire s_axi_mem_arready,
    input wire [2:0] s_axi_mem_arsize,
    input wire s_axi_mem_arvalid,

    input wire [31:0] s_axi_mem_awaddr,
    input wire [1:0] s_axi_mem_awburst,
    input wire [3:0] s_axi_mem_awcache,
    input wire [3:0] s_axi_mem_awid,
    input wire [7:0] s_axi_mem_awlen,
    input wire s_axi_mem_awlock,
    input wire [2:0] s_axi_mem_awprot,
    input wire s_axi_mem_awready,
    input wire [2:0] s_axi_mem_awsize,
    input wire s_axi_mem_awvalid,

    input wire [3:0] s_axi_mem_bid,
    input wire s_axi_mem_bready,
    input wire [1:0] s_axi_mem_bresp,
    input wire s_axi_mem_bvalid,

    input wire [31:0] s_axi_mem_rdata,
    input wire [3:0] s_axi_mem_rid,
    input wire s_axi_mem_rlast,
    input wire s_axi_mem_rready,
    input wire s_axi_mem_rresp,
    input wire s_axi_mem_rvalid,

    input wire [31:0] s_axi_mem_wdata,
    input wire s_axi_mem_wlast,
    input wire s_axi_mem_wready,
    input wire [3:0] s_axi_mem_wstrb,
    input wire s_axi_mem_wvalid
);

  // Internal signals for EMC to Flash memory interface
  wire [31:0] emc_addr;
  wire [31:0] emc_data_in;
  wire [31:0] emc_data_out;
  wire emc_cs_n;
  wire emc_we_n;
  wire emc_oe_n;
  wire emc_ready;

  // AXI EMC Instantiation
  axi_emc_0 u_axi_emc (
      // AXI4 Slave Interface
      .s_axi_aclk(s_axi_aclk),
      .s_axi_aresetn(s_axi_aresetn),

      // AXI Read Address Channel
      .s_axi_mem_araddr(s_axi_mem_araddr),
      .s_axi_mem_arburst(s_axi_mem_arburst),
      .s_axi_mem_arcache(s_axi_mem_arcache),
      .s_axi_mem_arid(s_axi_mem_arid),
      .s_axi_mem_arlen(s_axi_mem_arlen),
      .s_axi_mem_arlock(s_axi_mem_arlock),
      .s_axi_mem_arprot(s_axi_mem_arprot),
      .s_axi_mem_arready(s_axi_mem_arready),
      .s_axi_mem_arsize(s_axi_mem_arsize),
      .s_axi_mem_arvalid(s_axi_mem_arvalid),

      // AXI Write Address Channel
      .s_axi_mem_awaddr(s_axi_mem_awaddr),
      .s_axi_mem_awburst(s_axi_mem_awburst),
      .s_axi_mem_awcache(s_axi_mem_awcache),
      .s_axi_mem_awid(s_axi_mem_awid),
      .s_axi_mem_awlen(s_axi_mem_awlen),
      .s_axi_mem_awlock(s_axi_mem_awlock),
      .s_axi_mem_awprot(s_axi_mem_awprot),
      .s_axi_mem_awready(s_axi_mem_awready),
      .s_axi_mem_awsize(s_axi_mem_awsize),
      .s_axi_mem_awvalid(s_axi_mem_awvalid),

      // AXI Write Data Channel
      .s_axi_mem_wdata(s_axi_mem_wdata),
      .s_axi_mem_wlast(s_axi_mem_wlast),
      .s_axi_mem_wready(s_axi_mem_wready),
      .s_axi_mem_wstrb(s_axi_mem_wstrb),
      .s_axi_mem_wvalid(s_axi_mem_wvalid),

      // AXI Read Data Channel
      .s_axi_mem_rdata(s_axi_mem_rdata),
      .s_axi_mem_rid(s_axi_mem_rid),
      .s_axi_mem_rlast(s_axi_mem_rlast),
      .s_axi_mem_rready(s_axi_mem_rready),
      .s_axi_mem_rresp(s_axi_mem_rresp),
      .s_axi_mem_rvalid(s_axi_mem_rvalid),

      // AXI Write Response Channel
      .s_axi_mem_bid(s_axi_mem_bid),
      .s_axi_mem_bready(s_axi_mem_bready),
      .s_axi_mem_bresp(s_axi_mem_bresp),
      .s_axi_mem_bvalid(s_axi_mem_bvalid),

      // External Memory Interface
      .emc_addr(emc_addr),          // Address to Flash
      .emc_data_in(emc_data_in),    // Data from Flash
      .emc_data_out(emc_data_out),  // Data to Flash
      .emc_cs_n(emc_cs_n),          // Chip Select (Active Low)
      .emc_we_n(emc_we_n),          // Write Enable (Active Low)
      .emc_oe_n(emc_oe_n),          // Output Enable (Active Low)
      .emc_ready(emc_ready),        // Ready signal
      .rdclk(rdclk)                 // Read clock input
  );

  // Flash Memory Interface Mapping
  assign flash_addr = emc_addr;
  assign flash_data = emc_we_n ? 32'bz : emc_data_out;  // Tri-state data bus when not writing
  assign emc_data_in = flash_data;                     // Read data from Flash
  assign flash_cs_n = emc_cs_n;
  assign flash_we_n = emc_we_n;
  assign flash_oe_n = emc_oe_n;

endmodule
