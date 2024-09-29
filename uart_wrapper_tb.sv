module uart_wrapper_tb;

    // Inputs
    reg clk;
    reg resetn;
    reg [3:0] s_axi_awaddr;
    reg s_axi_awvalid;
    reg [31:0] s_axi_wdata;
    reg [3:0] s_axi_wstrb;
    reg s_axi_wvalid;
    reg s_axi_bready;
    reg [3:0] s_axi_araddr;
    reg s_axi_arvalid;
    reg s_axi_rready;
    reg rx;

    // Outputs
    wire s_axi_awready;
    wire s_axi_wready;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    wire s_axi_arready;
    wire [31:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;
    wire tx;
    wire interrupt;

    // Internal variables to store received data
    reg [31:0] received_data;

    // Instantiate the UART Wrapper
    uart_wrapper uut (
        .clk(clk),
        .resetn(resetn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .tx(tx),
        .rx(rx),
        .interrupt(interrupt)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Reset and stimulus
    initial begin
        // Initial values
        resetn = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        rx = 1;  // Idle state for UART receiver

        // Reset pulse
        #10 resetn = 1;

        // AXI Write operation
        $display("Starting AXI write...");
        #10 s_axi_awaddr = 4'h0;
        s_axi_awvalid = 1;
        s_axi_wdata = 32'hA1B2C3D4; // Sample 32-bit data
        s_axi_wstrb = 4'hF;
        s_axi_wvalid = 1;

        // Wait for write to complete
        #10 s_axi_awvalid = 0;
        #10 s_axi_wvalid = 0;
        s_axi_bready = 1;

        // Ensure write response is valid
        wait(s_axi_bvalid);
        #10 s_axi_bready = 0;

        // Send the instruction 8 bits at a time
        $display("Sending 32-bit data via UART...");
        #50 rx = 0; // Start bit
        #50 rx = 8'hD4; // First byte (least significant)
        #50 rx = 8'hC3; // Second byte
        #50 rx = 8'hB2; // Third byte
        #50 rx = 8'hA1; // Fourth byte (most significant)
        
        #50 rx = 1; // Stop bit

        // AXI Read operation to confirm
        $display("Starting AXI read...");
        #10 s_axi_araddr = 4'h0;
        s_axi_arvalid = 1;
        s_axi_rready = 1;

        // Wait for read to complete
        #10 s_axi_arvalid = 0;
        #10 s_axi_rready = 0;

        // Check that read data is valid
        wait(s_axi_rvalid);
        received_data = {8'hA1, 8'hB2, 8'hC3, 8'hD4}; // Expected data
        
        if (s_axi_rdata === received_data) begin
            $display("PASS: Correct data received via UART: 0x%H", s_axi_rdata);
        end else begin
            $display("FAIL: Incorrect data received. Expected: 0x%H, Got: 0x%H", received_data, s_axi_rdata);
        end

        // Simulate RX overrun case by sending more data before clearing RX buffer
        $display("Testing RX overrun...");
        #50 rx = 0; // Start bit
        #50 rx = 8'hFF; // Overrun byte (unexpected input)
        
        // TX Line check to ensure correct transmission
        if (tx !== 1'b1) begin
            $display("FAIL: TX line did not return to idle (1'b1) after transmission");
        end else begin
            $display("PASS: TX line returned to idle (1'b1) after transmission");
        end

        // Check for interrupt signal
        if (interrupt) begin
            $display("PASS: Interrupt signal asserted - TX complete");
        end else begin
            $display("FAIL: Interrupt signal not asserted");
        end

        // Additional AXI Write/Read cycles
        $display("Testing additional AXI Write/Read cycles...");
        #10 s_axi_awaddr = 4'h0;
        s_axi_awvalid = 1;
        s_axi_wdata = 32'h5A5A5A5A; // Another test data
        s_axi_wstrb = 4'hF;
        s_axi_wvalid = 1;

        #10 s_axi_awvalid = 0;
        #10 s_axi_wvalid = 0;
        s_axi_bready = 1;

        // Ensure write response is valid
        wait(s_axi_bvalid);
        #10 s_axi_bready = 0;

        #10 s_axi_araddr = 4'h0;
        s_axi_arvalid = 1;
        s_axi_rready = 1;
        #10 s_axi_arvalid = 0;
        #10 s_axi_rready = 0;

        // Check that read data is valid
        wait(s_axi_rvalid);
        received_data = 32'h5A5A5A5A; // Expected data

        if (s_axi_rdata === received_data) begin
            $display("PASS: Correct data received via AXI: 0x%H", s_axi_rdata);
        end else begin
            $display("FAIL: Incorrect data received. Expected: 0x%H, Got: 0x%H", received_data, s_axi_rdata);
        end

        #100 $finish;
    end

endmodule