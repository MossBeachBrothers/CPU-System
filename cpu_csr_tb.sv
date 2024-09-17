`timescale 1ns/1ps

module cpu_csr_tb;

    // ============================
    // 1. Clock and Reset Generation
    // ============================

    reg s_aclk = 0;
    reg s_aresetn = 0;

    always #5 s_aclk = ~s_aclk; // 100MHz Clock

    initial begin
        #20;
        s_aresetn = 1;
    end

    // ============================
    // 2. AXI Interface Signal Definitions
    // ============================

    // Read Address Channel
    reg [31:0]   s_axi_araddr;
    reg [1:0]    s_axi_arburst;
    reg [3:0]    s_axi_arid;
    reg [7:0]    s_axi_arlen;
    wire         s_axi_arready;
    reg [2:0]    s_axi_arsize;
    reg          s_axi_arvalid;

    // Write Address Channel
    reg [31:0]   s_axi_awaddr;
    reg [1:0]    s_axi_awburst;
    reg [3:0]    s_axi_awid;
    reg [7:0]    s_axi_awlen;
    wire         s_axi_awready;
    reg [2:0]    s_axi_awsize;
    reg          s_axi_awvalid;

    // Write Response Channel
    wire [3:0]   s_axi_bid;
    reg          s_axi_bready;
    wire [1:0]   s_axi_bresp;
    wire         s_axi_bvalid;

    // Read Data Channel
    wire [31:0]  s_axi_rdata;
    wire [3:0]   s_axi_rid;
    wire         s_axi_rlast;
    reg          s_axi_rready;
    wire [1:0]   s_axi_rresp;
    wire         s_axi_rvalid;

    // Write Data Channel
    reg [31:0]   s_axi_wdata;
    reg          s_axi_wlast;
    wire         s_axi_wready;
    reg [3:0]    s_axi_wstrb;
    reg          s_axi_wvalid;

    // Busy Signals
    wire         rsta_busy;
    wire         rstb_busy;

    // ============================
    // 3. Instantiate the DUT (Device Under Test)
    // ============================

    cpu_csr uut (
        .s_aclk        (s_aclk),
        .s_aresetn     (s_aresetn),
        .s_axi_araddr  (s_axi_araddr),
        .s_axi_arburst (s_axi_arburst),
        .s_axi_arid    (s_axi_arid),
        .s_axi_arlen   (s_axi_arlen),
        .s_axi_arready (s_axi_arready),
        .s_axi_arsize  (s_axi_arsize),
        .s_axi_arvalid (s_axi_arvalid),
        .s_axi_awaddr  (s_axi_awaddr),
        .s_axi_awburst (s_axi_awburst),
        .s_axi_awid    (s_axi_awid),
        .s_axi_awlen   (s_axi_awlen),
        .s_axi_awready (s_axi_awready),
        .s_axi_awsize  (s_axi_awsize),
        .s_axi_awvalid (s_axi_awvalid),
        .s_axi_bid     (s_axi_bid),
        .s_axi_bready  (s_axi_bready),
        .s_axi_bresp   (s_axi_bresp),
        .s_axi_bvalid  (s_axi_bvalid),
        .s_axi_rdata   (s_axi_rdata),
        .s_axi_rid     (s_axi_rid),
        .s_axi_rlast   (s_axi_rlast),
        .s_axi_rready  (s_axi_rready),
        .s_axi_rresp   (s_axi_rresp),
        .s_axi_rvalid  (s_axi_rvalid),
        .s_axi_wdata   (s_axi_wdata),
        .s_axi_wlast   (s_axi_wlast),
        .s_axi_wready  (s_axi_wready),
        .s_axi_wstrb   (s_axi_wstrb),
        .s_axi_wvalid  (s_axi_wvalid),
        .rsta_busy     (rsta_busy),
        .rstb_busy     (rstb_busy)
    );

    // ============================
    // 4. AXI Master Tasks
    // ============================

    // Task to perform AXI write
    task axi_write(
        input [3:0]   aw_id,
        input [31:0]  aw_addr,
        input [1:0]   aw_burst,
        input [7:0]   aw_len,
        input [2:0]   aw_size,
        input [31:0]  w_data,
        input [3:0]   w_strb,
        input         w_last
    );
    begin
        @(posedge s_aclk);
        s_axi_awid    = aw_id;
        s_axi_awaddr  = aw_addr;
        s_axi_awburst = aw_burst;
        s_axi_awlen   = aw_len;
        s_axi_awsize  = aw_size;
        s_axi_awvalid = 1'b1;

        wait (s_axi_awready);
        @(posedge s_aclk);
        s_axi_awvalid = 1'b0;

        @(posedge s_aclk);
        s_axi_wdata   = w_data;
        s_axi_wstrb   = w_strb;
        s_axi_wlast   = w_last;
        s_axi_wvalid  = 1'b1;

        wait (s_axi_wready);
        @(posedge s_aclk);
        s_axi_wvalid  = 1'b0;
        s_axi_wlast   = 1'b0;

        @(posedge s_aclk);
        s_axi_bready = 1'b1;

        wait (s_axi_bvalid);
        @(posedge s_aclk);
        s_axi_bready = 1'b0;
    end
    endtask

    // Task to perform AXI read
    task axi_read(
        input [3:0]   ar_id,
        input [31:0]  ar_addr,
        input [1:0]   ar_burst,
        input [7:0]   ar_len,
        input [2:0]   ar_size,
        output [31:0] r_data,
        output [3:0]  r_id,
        output        r_last
    );
        reg [31:0] data;
        reg [3:0]  id;
        reg        last;
    begin
        @(posedge s_aclk);
        s_axi_arid    = ar_id;
        s_axi_araddr  = ar_addr;
        s_axi_arburst = ar_burst;
        s_axi_arlen   = ar_len;
        s_axi_arsize  = ar_size;
        s_axi_arvalid = 1'b1;

        wait (s_axi_arready);
        @(posedge s_aclk);
        s_axi_arvalid = 1'b0;

        s_axi_rready = 1'b1;
        wait (s_axi_rvalid);
        data = s_axi_rdata;
        id   = s_axi_rid;
        last = s_axi_rlast;
        s_axi_rready = 1'b0;

        r_data = data;
        r_id   = id;
        r_last = last;
    end
    endtask

    // ============================
    // 5. Monitor and Checker
    // ============================

    // Monitor Write Responses
    always @(posedge s_aclk) begin
        if (s_axi_bvalid) begin
            $display("TIME=%0t: Write Response - ID=%0d, RESP=%b", $time, s_axi_bid, s_axi_bresp);
            if (s_axi_bresp !== 2'b00)
                $display("ERROR: Write Response not OKAY");
        end
    end

    // Monitor Read Responses
    always @(posedge s_aclk) begin
        if (s_axi_rvalid) begin
            $display("TIME=%0t: Read Data - ID=%0d, DATA=0x%h, LAST=%b, RESP=%b", 
                     $time, s_axi_rid, s_axi_rdata, s_axi_rlast, s_axi_rresp);
            if (s_axi_rresp !== 2'b00)
                $display("ERROR: Read Response not OKAY");
        end
    end

    // ============================
    // 6. Test Cases
    // ============================

    initial begin
        // Variable Declarations
        reg [31:0] read_data1;
        reg [3:0]  read_id1;
        reg        read_last1;

        reg [31:0] read_data2;
        reg [3:0]  read_id2;
        reg        read_last2;

        reg [31:0] read_data3;
        reg [3:0]  read_id3;
        reg        read_last3;

        reg [31:0] read_data4;
        reg [3:0]  read_id4;
        reg        read_last4;

        reg [31:0] read_data5;
        reg [3:0]  read_id5;
        reg        read_last5;

        reg [31:0] read_data6;
        reg [3:0]  read_id6;
        reg        read_last6;

        integer rand_reg;
        integer rand_data;
        reg [31:0] read_data_rand;
        reg [3:0]  read_id_rand;
        reg        read_last_rand;

        // Wait for reset deassertion
        wait (s_aresetn == 1);
        #10;

        // Test Case 1: Single Write and Read
        axi_write(4'd1, 32'd20, 2'b00, 8'd0, 3'd2, 32'hDEADBEEF, 4'b1111, 1'b1);
        axi_read(4'd1, 32'd20, 2'b00, 8'd0, 3'd2, read_data1, read_id1, read_last1);
        if (read_data1 !== 32'hDEADBEEF)
            $display("ERROR: Test Case 1 Failed - Expected 0xDEADBEEF, Got 0x%h", read_data1);
        else
            $display("PASS: Test Case 1 - Single Write and Read Successful");

        #20;

        // Test Case 2: Burst Write and Read
        for (int i = 0; i < 5; i++) begin
            axi_write(4'd2, 32'd40 + i*4, 2'b01, 8'd4, 3'd2, 32'hAAAA0000 + i, 4'b1111, (i == 4));
        end
        for (int i = 0; i < 5; i++) begin
            axi_read(4'd2, 32'd40 + i*4, 2'b01, 8'd4, 3'd2, read_data2, read_id2, read_last2);
            if (read_data2 !== (32'hAAAA0000 + i))
                $display("ERROR: Test Case 2 Failed at Register %0d - Expected 0x%h, Got 0x%h", 10+i, (32'hAAAA0000 + i), read_data2);
            else
                $display("PASS: Test Case 2 - Burst Read Register %0d Successful", 10+i);
        end

        #20;

        // Test Case 3: Write with Byte Strobes
        axi_write(4'd3, 32'd60, 2'b00, 8'd0, 3'd2, 32'h0000BEEF, 4'b0011, 1'b1);
        axi_read(4'd3, 32'd60, 2'b00, 8'd0, 3'd2, read_data3, read_id3, read_last3);
        if (read_data3 !== 32'h0000BEEF)
            $display("ERROR: Test Case 3 Failed - Expected 0x0000BEEF, Got 0x%h", read_data3);
        else
            $display("PASS: Test Case 3 - Write with Byte Strobes Successful");

        #20;

        // Test Case 4: Boundary Conditions
        axi_write(4'd4, 32'd0, 2'b00, 8'd0, 3'd2, 32'h12345678, 4'b1111, 1'b1);
        axi_read(4'd4, 32'd0, 2'b00, 8'd0, 3'd2, read_data4, read_id4, read_last4);
        if (read_data4 !== 32'h12345678)
            $display("ERROR: Test Case 4 Failed at Register 0 - Expected 0x12345678, Got 0x%h", read_data4);
        else
            $display("PASS: Test Case 4 - Boundary Condition Register 0 Successful");

        axi_write(4'd5, 32'd124, 2'b00, 8'd0, 3'd2, 32'hCAFEBABE, 4'b1111, 1'b1);
        axi_read(4'd5, 32'd124, 2'b00, 8'd0, 3'd2, read_data5, read_id5, read_last5);
        if (read_data5 !== 32'hCAFEBABE)
            $display("ERROR: Test Case 4 Failed at Register 31 - Expected 0xCAFEBABE, Got 0x%h", read_data5);
        else
            $display("PASS: Test Case 4 - Boundary Condition Register 31 Successful");

        #20;

        // Test Case 5: Reset Behavior
        axi_write(4'd6, 32'd20, 2'b00, 8'd0, 3'd2, 32'hFACEB00C, 4'b1111, 1'b1);
        axi_read(4'd6, 32'd20, 2'b00, 8'd0, 3'd2, read_data6, read_id6, read_last6);
        if (read_data6 !== 32'hFACEB00C)
            $display("ERROR: Test Case 5 Failed - Expected 0xFACEB00C, Got 0x%h", read_data6);
        else
            $display("PASS: Test Case 5 - Pre-Reset Write and Read Successful");

        @(posedge s_aclk);
        s_aresetn = 0;
        @(posedge s_aclk);
        s_aresetn = 1;
        #20;

        axi_read(4'd6, 32'd20, 2'b00, 8'd0, 3'd2, read_data6, read_id6, read_last6);
        if (read_data6 !== 32'd0)
            $display("ERROR: Test Case 5 Failed - Post-Reset Read mismatch. Expected 0x00000000, Got 0x%h", read_data6);
        else
            $display("PASS: Test Case 5 - Reset Behavior Successful");

        #20;

        // Test Case 6: Randomized Write and Read
        for (int i = 0; i < 10; i++) begin
            rand_reg  = $urandom_range(0, 31);
            rand_data = $urandom;
            axi_write(4'd10 + i, rand_reg * 4, 2'b00, 8'd0, 3'd2, rand_data, 4'b1111, 1'b1);
            axi_read(4'd10 + i, rand_reg * 4, 2'b00, 8'd0, 3'd2, read_data_rand, read_id_rand, read_last_rand);
            if (read_data_rand !== rand_data)
                $display("ERROR: Test Case 6 Failed at Register %0d - Expected 0x%h, Got 0x%h", rand_reg, rand_data, read_data_rand);
            else
                $display("PASS: Test Case 6 - Randomized Write/Read Successful at Register %0d", rand_reg);
        end

        #20;
        $display("\n=== TESTBENCH COMPLETE ===");
        $stop;
    end

endmodule
