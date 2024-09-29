module program_counter_tb;
    logic clk;
    logic rst_n;
    logic [31:0] jump_address;
    logic branch_taken;
    logic [31:0] pc_out;

    // Instantiate the Program Counter
    program_counter pc (
        .clk(clk),
        .rst_n(rst_n),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .pc_out(pc_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        jump_address = 32'h0;
        branch_taken = 0;

        // Release reset
        #10 rst_n = 1;

        // Test normal increment
        #10;
        if (pc_out !== 32'd0) $error("Test failed: PC should be 0 after reset.");
        else $display("Test passed: PC initialized to 0.");

        // Increment PC without branching
        #10;
        if (pc_out !== 32'd4) $error("Test failed: PC should be 4 after one increment.");
        else $display("Test passed: PC is now 4.");

        // Test branching
        jump_address = 32'hA0; // Arbitrary jump address
        branch_taken = 1;
        #10;
        if (pc_out !== 32'hA0) $error("Test failed: PC should be updated to A0 on branch.");
        else $display("Test passed: PC is now A0 on branch.");

        // Back to normal increment
        branch_taken = 0;
        #10;
        if (pc_out !== 32'hA4) $error("Test failed: PC should be A4 after incrementing from A0.");
        else $display("Test passed: PC is now A4 after incrementing.");

        // Finish simulation
        #10;
        $finish;
    end
endmodule
