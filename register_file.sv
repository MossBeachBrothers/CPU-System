module register_file (
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire re,
    input wire [4:0] addr,
    input wire [31:0] wdata,
    output wire [31:0] rdata,
    output wire busy,
    output wire read_valid,
    output wire write_resp_valid,
    output wire [1:0] write_resp
);

    // AXI signals
    reg [4:0] s_axi_araddr, s_axi_awaddr;
    reg s_axi_arvalid, s_axi_awvalid, s_axi_wvalid, s_axi_bready, s_axi_rready;
    wire s_axi_arready, s_axi_awready, s_axi_wready, s_axi_bvalid, s_axi_rvalid;
    reg [31:0] s_axi_wdata;
    wire [31:0] s_axi_rdata;
    wire [1:0] s_axi_bresp, s_axi_rresp;
    wire s_axi_rlast;

    // State machine
    reg [1:0] state;
    localparam IDLE = 2'b00, WRITE = 2'b01, READ = 2'b10, WAIT = 2'b11;

    // Busy signal
    assign busy = (state != IDLE);

    // Output assignments
    assign rdata = s_axi_rdata;
    assign read_valid = s_axi_rvalid;
    assign write_resp_valid = s_axi_bvalid;
    assign write_resp = s_axi_bresp;

    // State machine logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            s_axi_arvalid <= 1'b0;
            s_axi_awvalid <= 1'b0;
            s_axi_wvalid <= 1'b0;
            s_axi_bready <= 1'b0;
            s_axi_rready <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (we) begin
                        state <= WRITE;
                        s_axi_awaddr <= addr;
                        s_axi_wdata <= wdata;
                        s_axi_awvalid <= 1'b1;
                        s_axi_wvalid <= 1'b1;
                        s_axi_bready <= 1'b1;
                    end else if (re) begin
                        state <= READ;
                        s_axi_araddr <= addr;
                        s_axi_arvalid <= 1'b1;
                        s_axi_rready <= 1'b1;
                    end
                end
                WRITE: begin
                    if (s_axi_awready && s_axi_wready) begin
                        s_axi_awvalid <= 1'b0;
                        s_axi_wvalid <= 1'b0;
                        state <= WAIT;
                    end
                end
                READ: begin
                    if (s_axi_arready) begin
                        s_axi_arvalid <= 1'b0;
                        state <= WAIT;
                    end
                end
                WAIT: begin
                    if (s_axi_bvalid || s_axi_rvalid) begin
                        s_axi_bready <= 1'b0;
                        s_axi_rready <= 1'b0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // Instantiate the cpu_csr module
    cpu_csr cpu_csr_inst (
        .s_aclk(clk),
        .s_aresetn(rst_n),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(2'b01),  // INCR burst type
        .s_axi_arid(5'b0),
        .s_axi_arlen(8'b0),
        .s_axi_arready(s_axi_arready),
        .s_axi_arsize(3'b010),  // 4 bytes (32 bits) per transfer
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(2'b01),  // INCR burst type
        .s_axi_awid(5'b0),
        .s_axi_awlen(8'b0),
        .s_axi_awready(s_axi_awready),
        .s_axi_awsize(3'b010),  // 4 bytes (32 bits) per transfer
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(1'b1),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(4'b1111),
        .s_axi_wvalid(s_axi_wvalid),
        .rsta_busy(),
        .rstb_busy()
    );

endmodule