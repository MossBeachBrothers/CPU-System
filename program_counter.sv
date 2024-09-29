module program_counter (
    input logic clk,
    input logic rst_n,
    input logic [31:0] jump_address,
    input logic branch_taken,
    output logic [31:0] pc_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 32'd0; // Reset PC to 0
        end else if (branch_taken) begin
            pc_out <= jump_address; // Load new PC value on branch
        end else begin
            pc_out <= pc_out + 4; // Increment PC
        end
    end
endmodule
