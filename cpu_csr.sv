module cpu_csr (
    // AXI Clock and Reset
    input  wire          s_aclk,       // AXI clock signal
    input  wire          s_aresetn,    // AXI reset signal (active-low)

    // AXI Slave Read Address Channel
    input  wire [31:0]   s_axi_araddr,  // Read address
    input  wire [1:0]    s_axi_arburst, // Burst type
    input  wire [3:0]    s_axi_arid,    // Transaction ID
    input  wire [7:0]    s_axi_arlen,   // Burst length
    output reg           s_axi_arready, // Read address ready
    input  wire [2:0]    s_axi_arsize,  // Burst size
    input  wire          s_axi_arvalid, // Read address valid

    // AXI Slave Write Address Channel
    input  wire [31:0]   s_axi_awaddr,  // Write address
    input  wire [1:0]    s_axi_awburst, // Burst type
    input  wire [3:0]    s_axi_awid,    // Write transaction ID
    input  wire [7:0]    s_axi_awlen,   // Burst length
    output reg           s_axi_awready, // Write address ready
    input  wire [2:0]    s_axi_awsize,  // Burst size
    input  wire          s_axi_awvalid, // Write address valid

    // AXI Slave Write Response Channel
    output reg [3:0]     s_axi_bid,     // Write response transaction ID
    input  wire          s_axi_bready,  // Write response ready
    output reg [1:0]     s_axi_bresp,   // Write response
    output reg           s_axi_bvalid,  // Write response valid

    // AXI Slave Read Data Channel
    output reg [31:0]    s_axi_rdata,   // Read data
    output reg [3:0]     s_axi_rid,     // Read transaction ID
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

    // Register File: 32 registers of 32-bit width
    reg [31:0] regfile [31:0];
    reg [4:0]  reg_addr;       // 5-bit register address for 32 registers
    reg [7:0]  burst_counter;  // Burst length counter
    reg [1:0]  burst_type;     // Burst type storage (for ARBURST/AWBURST)

    // Store Transaction IDs for Read and Write
    reg [3:0]  stored_arid;
    reg [3:0]  stored_awid;

    // Initialize Register File on Reset
    integer i;
    always @(posedge s_aclk) begin
        if (~s_aresetn) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] <= 32'd0;
            end
        end
    end

    // AXI Read and Write ready logic
    always @(posedge s_aclk) begin
        if (~s_aresetn) begin
            // Reset all control signals
            s_axi_arready <= 1'b1;  // Ready to accept read address
            s_axi_awready <= 1'b1;  // Ready to accept write address
            s_axi_rvalid  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            s_axi_wready  <= 1'b0;
            burst_counter <= 8'd0;
            burst_type    <= 2'b00;
            s_axi_rresp   <= 2'b00;
            s_axi_bresp   <= 2'b00;
            s_axi_rlast   <= 1'b0;
            s_axi_rid     <= 4'd0;
            s_axi_bid     <= 4'd0;
            stored_arid   <= 4'd0;
            stored_awid   <= 4'd0;
        end else begin
            // Handle AXI read address
            if (s_axi_arvalid && s_axi_arready && burst_counter == 0) begin
                reg_addr      <= s_axi_araddr[6:2];  // Extract 5-bit register address
                burst_counter <= s_axi_arlen + 8'd1; // AXI arlen is burst length minus one
                burst_type    <= s_axi_arburst;
                stored_arid    <= s_axi_arid;        // Store read transaction ID
                s_axi_arready <= 1'b0;               // Not ready to accept another read address
            end else if (burst_counter > 0) begin
                s_axi_arready <= 1'b0;               // Not ready during an ongoing read
            end else begin
                s_axi_arready <= 1'b1;               // Ready to accept read address
            end

            // Handle AXI read data
            if (burst_counter > 0 && s_axi_arvalid && !s_axi_rvalid) begin
                s_axi_rdata <= regfile[reg_addr];
                s_axi_rid   <= stored_arid;
                s_axi_rresp <= 2'b00;               // OKAY response
                s_axi_rvalid <= 1'b1;
                s_axi_rlast  <= (burst_counter == 1);
                burst_counter <= burst_counter - 1;
                if (burst_type == 2'b01) begin      // INCR burst
                    reg_addr <= reg_addr + 1;
                end
            end else if (s_axi_rvalid && s_axi_rready) begin
                if (burst_counter > 0) begin
                    s_axi_rdata <= regfile[reg_addr];
                    s_axi_rid   <= stored_arid;
                    s_axi_rresp <= 2'b00;           // OKAY response
                    s_axi_rlast  <= (burst_counter == 1);
                    burst_counter <= burst_counter - 1;
                    if (burst_type == 2'b01) begin  // INCR burst
                        reg_addr <= reg_addr + 1;
                    end
                end else begin
                    s_axi_rvalid <= 1'b0;
                    s_axi_rlast  <= 1'b0;
                    s_axi_rid    <= 4'd0;
                end
            end

            // Handle AXI write address
            if (s_axi_awvalid && s_axi_awready && burst_counter == 0) begin
                reg_addr      <= s_axi_awaddr[6:2];  // Extract 5-bit register address
                burst_counter <= s_axi_awlen + 8'd1; // AXI awlen is burst length minus one
                burst_type    <= s_axi_awburst;
                stored_awid    <= s_axi_awid;        // Store write transaction ID
                s_axi_awready <= 1'b0;               // Not ready to accept another write address
            end else if (burst_counter > 0) begin
                s_axi_awready <= 1'b0;               // Not ready during an ongoing write
            end else begin
                s_axi_awready <= 1'b1;               // Ready to accept write address
            end

            // Handle AXI write data
            if (s_axi_wvalid && s_axi_awready && burst_counter > 0) begin
                s_axi_wready <= 1'b1;
                // Write data to register file based on write strobes
                for (int i = 0; i < 4; i++) begin
                    if (s_axi_wstrb[i]) begin
                        regfile[reg_addr][8*i +: 8] <= s_axi_wdata[8*i +: 8];
                    end
                end
                if (burst_type == 2'b01) begin      // INCR burst
                    reg_addr <= reg_addr + 1;
                end
                burst_counter <= burst_counter - 1;
                if (s_axi_wlast || burst_counter == 1) begin
                    s_axi_bvalid <= 1'b1;
                    s_axi_bid     <= stored_awid;
                    s_axi_bresp   <= 2'b00;           // OKAY response
                end
            end else begin
                s_axi_wready <= 1'b0;
            end

            // Handle AXI write response
            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
                s_axi_bid     <= 4'd0;
                s_axi_bresp   <= 2'b00;
            end
        end
    end

    // Optional busy signals (not implemented)
    assign rsta_busy = 1'b0;
    assign rstb_busy = 1'b0;

endmodule
