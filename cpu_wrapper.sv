module cpu_wrapper(
    input wire clk,
    input wire reset_n
);

wire core_clk;
wire pll_locked;

pll_wrapper pll_wrapper_i (
    .clk_in(clk),
    .resetn(reset_n),
    .clk_out1(core_clk),
    .clk_out2(),
    .locked(pll_locked)
);

cpu_core core_i (
    .clk(core_clk),
    .reset_n(reset_n)
);

start_sequence start_sequence_i (
    .clk(core_clk),
    .reset_n(reset_n)
);

peripheral peripheral_i (
    .clk(core_clk),
    .reset_n(reset_n)
);

endmodule
