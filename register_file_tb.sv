module register_file_tb;

    reg clk;
    reg reset_n;

    // Simplified interface signals
    reg write_enable;
    reg [4:0] write_address;
    reg [31:0] write_data;
    reg read_enable;
    reg [4:0] read_address;

    // Outputs
    wire [31:0] read_data;
    wire read_data_valid;

    // Instantiate the register_file module
    register_file uut (
        .clk(clk),
        .reset_n(reset_n),
        .write_enable(write_enable),
        .write_address(write_address),
        .write_data(write_data),
        .read_enable(read_enable),
        .read_address(read_address),
        .read_data(read_data),
        .read_data_valid(read_data_valid)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        write_enable = 0;
        read_enable = 0;
        write_address = 0;
        write_data = 0;
        read_address = 0;

        // Release reset
        #10 reset_n = 1; 

        // Run tests
        test_write_read();
        test_edge_cases();
        
        // End simulation
        #50 $finish;
    end

    always #5 clk = ~clk; // Clock generation

    // Task to perform write and read operations
    task test_write_read();
        begin
            // Write to address 5
            write_enable = 1;
            write_address = 5;
            write_data = 32'hA5A5A5A5;
            #10;

            // Disable write
            write_enable = 0;

            // Read from address 5
            read_enable = 1;
            read_address = 5;
            #10;

            // Wait for read to be valid
            if (read_data_valid) begin
                $display("Read Data from Address %d: 0x%h (Expected: 0xA5A5A5A5)", read_address, read_data);
            end else begin
                $display("Read Data not valid");
            end

            // Additional writes and reads
            write_enable = 1;
            write_address = 10;
            write_data = 32'hDEADBEEF;
            #10;
            write_enable = 0;

            read_enable = 1;
            read_address = 10;
            #10;

            if (read_data_valid) begin
                $display("Read Data from Address %d: 0x%h (Expected: 0xDEADBEEF)", read_address, read_data);
            end else begin
                $display("Read Data not valid");
            end

            // Reset read_enable for next test
            read_enable = 0;
        end
    endtask

    // Task to test edge cases
    task test_edge_cases();
        begin
            // Attempt to read from an invalid address
            read_enable = 1;
            read_address = 31; // Out of bounds for testing
            #10;

            if (read_data_valid) begin
                $display("Read from Address %d: 0x%h (Expected: 0x00000000)", read_address, read_data);
            end else begin
                $display("Read Data not valid");
            end

            // Write to an address and read back
            write_enable = 1;
            write_address = 15;
            write_data = 32'h12345678;
            #10;
            write_enable = 0;

            read_enable = 1;
            read_address = 15;
            #10;

            if (read_data_valid) begin
                $display("Read Data from Address %d: 0x%h (Expected: 0x12345678)", read_address, read_data);
            end else begin
                $display("Read Data not valid");
            end

            // Check multiple writes to the same address
            write_enable = 1;
            write_address = 15;
            write_data = 32'hFFFFFFFF;
            #10;
            write_enable = 0;

            // Read again
            read_enable = 1;
            read_address = 15;
            #10;

            if (read_data_valid) begin
                $display("Read Data from Address %d after overwrite: 0x%h (Expected: 0xFFFFFFFF)", read_address, read_data);
            end else begin
                $display("Read Data not valid");
            end

            // Final cleanup
            read_enable = 0;
        end
    endtask
endmodule
