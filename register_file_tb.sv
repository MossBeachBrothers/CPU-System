`timescale 1ns / 1ps

module register_file_tb();

    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)

    // Signals
    reg clk;
    reg rst_n;
    reg we;
    reg re;
    reg [4:0] addr;
    reg [31:0] wdata;
    wire [31:0] rdata;
    wire busy;
    wire read_valid;
    wire write_resp_valid;
    wire [1:0] write_resp;

    // Instantiate the register_file
    register_file uut (
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .re(re),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata),
        .busy(busy),
        .read_valid(read_valid),
        .write_resp_valid(write_resp_valid),
        .write_resp(write_resp)
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    // Test procedure
    initial begin
        // Initialize signals
        rst_n = 0;
        we = 0;
        re = 0;
        addr = 0;
        wdata = 0;

        // Reset
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD*2);

        // Test write operations
        for (int i = 0; i < 5; i = i + 1) begin
            write_data(i, 32'hA0A0_0000 + i);
            #(CLK_PERIOD*10);
        end

        // Test read operations
        for (int i = 0; i < 5; i = i + 1) begin
            read_data(i);
            #(CLK_PERIOD*10);
        end

        // End simulation
        #(CLK_PERIOD*10);
        $finish;
    end

    // Write task
    task write_data(input [4:0] write_addr, input [31:0] write_data);
        begin
            $display("Writing 0x%h to address %0d", write_data, write_addr);
            @(posedge clk);
            addr = write_addr;
            wdata = write_data;
            we = 1'b1;
            @(posedge clk);
            we = 1'b0;
            wait(!busy);
            if (write_resp_valid) begin
                $display("Write response: %0d", write_resp);
            end else begin
                $display("Error: No write response received");
            end
        end
    endtask

    // Read task
    task read_data(input [4:0] read_addr);
        begin
            $display("Reading from address %0d", read_addr);
            @(posedge clk);
            addr = read_addr;
            re = 1'b1;
            @(posedge clk);
            re = 1'b0;
            wait(!busy);
            if (read_valid) begin
                $display("Read data: 0x%h", rdata);
            end else begin
                $display("Error: No valid read data received");
            end
        end
    endtask

    // Monitor for busy signal
    always @(posedge clk) begin
        if (busy) begin
            $display("Busy signal asserted at time %0t", $time);
        end
    end

endmodule