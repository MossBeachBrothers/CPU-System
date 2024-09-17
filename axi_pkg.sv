package axi_pkg;

  typedef struct packed {
    logic [31:0]  awaddr;
    logic [7:0]   awlen;
    logic [2:0]   awsize;
    logic [1:0]   awburst;
    logic         awvalid;
  } axi_aw_request_t;

  typedef struct packed {
    logic [31:0]  wdata;
    logic [3:0]   wstrb;
    logic         wlast;
    logic         wvalid;
  } axi_w_request_t;

  typedef struct packed {
    logic [31:0]  araddr;
    logic [7:0]   arlen;
    logic [2:0]   arsize;
    logic [1:0]   arburst;
    logic         arvalid;
  } axi_ar_request_t;

  typedef struct packed {
    logic         bready;
  } axi_b_request_t;

  typedef struct packed {
    logic         rready;
  } axi_r_request_t;

  typedef struct packed {
    axi_aw_request_t aw;
    axi_w_request_t  w;
    axi_ar_request_t ar;
    axi_b_request_t  b;
    axi_r_request_t  r;
  } axi_request_t;


  typedef struct packed {
    logic         awready;
  } axi_aw_response_t;

  typedef struct packed {
    logic         wready;
  } axi_w_response_t;

  typedef struct packed {
    logic         arready;
  } axi_ar_response_t;

  typedef struct packed {
    logic [1:0]   bresp
    logic         bvalid;
  } axi_b_response_t;

  typedef struct packed {
    logic [31:0]  rdata;
    logic [1:0]   rresp;
    logic         rvalid;
  } axi_r_response_t;

  typedef struct packed {
    axi_aw_response_t aw;
    axi_w_response_t  w;
    axi_ar_response_t ar;
    axi_b_response_t  b;
    axi_r_response_t  r;
  } axi_response_t;

endpackage : axi_pkg

