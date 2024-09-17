package axi_pkg;

  // Define the Write Address Channel for AXI request
  typedef struct packed {
    logic [31:0]  awaddr;    // Write address
    logic [7:0]   awlen;     // Burst length
    logic [2:0]   awsize;    // Transfer size (3'b010 for 4 bytes)
    logic [1:0]   awburst;   // Burst type (INCR = 2'b01)
    logic         awvalid;   // Write address valid
  } axi_aw_request_t;

  // Define the Write Data Channel for AXI request
  typedef struct packed {
    logic [31:0]  wdata;     // Write data
    logic [3:0]   wstrb;     // Write strobe (indicating which byte lanes are valid)
    logic         wlast;     // Last write in burst
    logic         wvalid;    // Write data valid
  } axi_w_request_t;

  // Define the Read Address Channel for AXI request
  typedef struct packed {
    logic [31:0]  araddr;    // Read address
    logic [7:0]   arlen;     // Burst length
    logic [2:0]   arsize;    // Transfer size (3'b010 for 4 bytes)
    logic [1:0]   arburst;   // Burst type (INCR = 2'b01)
    logic         arvalid;   // Read address valid signal
  } axi_ar_request_t;

  // Combine all the AXI request channels into a single struct
  typedef struct packed {
    axi_aw_request_t aw;     // Write address channel
    axi_w_request_t  w;      // Write data channel
    axi_ar_request_t ar;     // Read address channel
  } axi_request_t;

endpackage : axi_pkg
