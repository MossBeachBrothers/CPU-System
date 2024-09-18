module register_file (
    input wire clk,
    input wire reset_n,

    // Simplified interface
    input wire write_enable,
    input wire [4:0] write_address,  // Address for the 32 registers
    input wire [31:0] write_data,
    input wire read_enable,
    input wire [4:0] read_address,
    
    output reg [31:0] read_data,
    output reg read_data_valid
);

    // AXI signals
    wire s_axi_araddr = read_address;       // Read address
    wire s_axi_arvalid = read_enable;        // Read valid
    wire s_axi_awaddr = write_address;       // Write address
    wire s_axi_awvalid = write_enable;       // Write valid
    wire [31:0] s_axi_wdata = write_data;    // Write data
    wire s_axi_wvalid = write_enable;        // Write valid
    wire s_axi_bready = 1'b1;                // Always ready to receive write response
    wire s_axi_rready = 1'b1;                // Always ready to receive read data

    // AXI connections to the cpu_csr module
    wire [4:0] s_axi_bid;
    wire s_axi_bvalid;
    wire [1:0] s_axi_bresp;

    wire [31:0] s_axi_rdata;
    wire s_axi_rvalid;
    wire [1:0] s_axi_rresp;

    // Instantiate the cpu_csr module
    cpu_csr csr_inst (
        .s_aclk(clk),
        .s_aresetn(reset_n),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(),  // Not used in this context
        .s_axi_arburst(2'b00), // Default value for burst type
        .s_axi_arid(5'd0),     // Default ID
        .s_axi_arlen(8'd0),    // Default length
        .s_axi_arsize(3'b010), // Default size
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(),      // Not used in this context
        .s_axi_awburst(2'b00), // Default value for burst type
        .s_axi_awid(5'd0),     // Default ID
        .s_axi_awlen(8'd0),    // Default length
        .s_axi_awsize(3'b010), // Default size
        .s_axi_bid(s_axi_bid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(),          // Not used in this context
        .s_axi_rlast(),        // Not used in this context
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(1'b1),    // Assuming single beat writes
        .s_axi_wready(),       // Not used in this context
        .s_axi_wstrb(4'b1111), // Write all bytes
        .s_axi_wvalid(s_axi_wvalid),
        .rsta_busy(),          // Not used in this context
        .rstb_busy()           // Not used in this context
    );

    // Read data handling
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            read_data <= 32'd0;
            read_data_valid <= 1'b0;
        end else if (s_axi_rvalid) begin
            read_data <= s_axi_rdata;
            read_data_valid <= 1'b1;
        end else begin
            read_data_valid <= 1'b0;
        end
    end
endmodule
