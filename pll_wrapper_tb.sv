`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2024 12:44:26 PM
// Design Name: 
// Module Name: pll_wrapper_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - F ile Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pll_wrapper_tb;

    // Testbench signals
    reg clk_in;          // Primary clock input to the PLL wrapper
    reg resetn;          // Active-low reset signal

    wire clk_out1;       // Clock output 1 from the PLL wrapper
    wire clk_out2;       // Clock output 2 from the PLL wrapper
    wire locked;         // PLL locked status signal

    // Clock period (100 MHz input clock)
    localparam CLK_PERIOD = 10;  // 10 ns period corresponds to 100 MHz

    // Instantiate the Unit Under Test (UUT)
    pll_wrapper uut (
        .clk_in(clk_in),
        .resetn(resetn),
        .clk_out1(clk_out1),
        .clk_out2(clk_out2),
        .locked(locked)
    );

    // Clock generation: 100 MHz clock
    initial begin
        clk_in = 0;
        forever #(CLK_PERIOD/2) clk_in = ~clk_in;  // Toggle every half period
    end

    // Test procedure
    initial begin
        // Initialize reset to active (asserted)
        resetn = 0;
        #20;  // Hold reset for 20 ns

        // Deassert reset to start the PLL
        resetn = 1;
        $display("[%0t] Deasserting reset.", $time);

        // Wait for the PLL to lock
        wait(locked == 1);
        $display("[%0t] PLL locked.", $time);

        // Observe clocks after lock
        #500;  // Wait for 500 ns after lock to observe clk_out1 and clk_out2

        // Reassert reset to test reset functionality
        $display("[%0t] Reasserting reset.", $time);
        resetn = 0;
        #50;  // Hold reset for 50 ns

        // Deassert reset again
        resetn = 1;
        $display("[%0t] Deasserting reset.", $time);

        // Wait for PLL to lock again
        wait(locked == 1);
        $display("[%0t] PLL locked again.", $time);

        // Run simulation for some time to observe outputs
        #1000;

        // End simulation
        $display("[%0t] Simulation completed.", $time);
        $stop;
    end

    // Signal monitoring
    initial begin
        $monitor("[%0t] clk_in = %b, resetn = %b, clk_out1 = %b, clk_out2 = %b, locked = %b", 
                 $time, clk_in, resetn, clk_out1, clk_out2, locked);
    end

endmodule