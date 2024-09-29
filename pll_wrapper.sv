`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MossBeachBros
// Engineer: Akhil Nair
// 
// Create Date: 08/29/2024 03:55:31 PM
// Design Name: PLL Wrapper
// Module Name: pll_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Wrapper module for the PLL generated using the Xilinx Clocking Wizard IP
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module pll_wrapper(
    input wire clk_in,          // Primary clock input
    input wire resetn,          // Active-low reset input
    output wire clk_out1,       // Clock output 1
    output wire clk_out2,       // Clock output 2 (if needed)
    output wire locked          // PLL lock status signal
    // Add additional clock outputs if needed
);

    // Instantiate the Clocking Wizard IP
    clk_wiz_0 clk_wiz_inst (
        .clk_in1(clk_in),       // Connect input clock
        .reset(~resetn),        // Active-high reset for the IP (inverted resetn)
        .clk_out1(clk_out1),    // Connect output clock 1
        .clk_out2(clk_out2),    // Connect output clock 2 (if needed)
        .locked(locked)         // Connect PLL locked signal
    );

endmodule