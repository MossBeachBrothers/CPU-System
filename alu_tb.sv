`timescale 1ns / 1ps

module alu_tb;

    // ALU inputs
    logic [6:0] opcode;
    logic [4:0] rd, rs1_addr, rs2_addr;
    logic [2:0] funct3, instr_type;
    logic [6:0] funct7;
    logic [31:0] imm, pc, rs1_data, rs2_data;

    // ALU outputs
    logic [31:0] alu_result;
    logic branch_taken;

    // Instantiate the ALU
    alu uut (
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .funct7(funct7),
        .imm(imm),
        .instr_type(instr_type),
        .pc(pc),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .alu_result(alu_result),
        .branch_taken(branch_taken)
    );

    // Task to check expected output
    task check_output(input logic [31:0] expected_result, input logic expected_branch);
        if (alu_result === expected_result && branch_taken === expected_branch) begin
            $display("TEST PASSED: alu_result = %0d, branch_taken = %b", alu_result, branch_taken);
        end else begin
            $display("TEST FAILED: Expected alu_result = %0d, branch_taken = %b. Got alu_result = %0d, branch_taken = %b",
                      expected_result, expected_branch, alu_result, branch_taken);
        end
    endtask

    // Test vectors
    initial begin
        $display("Starting ALU Test Bench...");

        // Initialize all inputs
        opcode = 7'b0;
        rd = 5'b0;
        funct3 = 3'b0;
        rs1_addr = 5'b0;
        rs2_addr = 5'b0;
        funct7 = 7'b0;
        imm = 32'b0;
        pc = 32'b0;
        rs1_data = 32'b0;
        rs2_data = 32'b0;

        // Open the waveform dump for ModelSim (for waveform viewing)
        $dumpfile("alu_tb_waveform.vcd"); 
        $dumpvars(0, alu_tb);  // Dump all variables to waveform file
        
        // Test 1: ADD (R-type)
        #5 opcode = 7'b0110011;  // R-type
        funct3 = 3'b000;         // ADD
        funct7 = 7'b0000000;     // FUNCT7 for ADD
        rs1_data = 32'd10;
        rs2_data = 32'd20;
        #10 check_output(32'd30, 1'b0); // Expected ALU result = 30, no branch
        $display("ADD Operation: rs1 = %0d, rs2 = %0d, alu_result = %0d", rs1_data, rs2_data, alu_result);

        // Test 2: SUB (R-type)
        funct7 = 7'b0100000;     // FUNCT7 for SUB
        #10 check_output($signed(32'd10 - 32'd20), 1'b0); // Expected ALU result = -10, no branch
        $display("SUB Operation: rs1 = %0d, rs2 = %0d, alu_result = %0d", rs1_data, rs2_data, alu_result);

        // Test 3: SLT (R-type, signed comparison)
        funct3 = 3'b010;         // SLT
        rs1_data = 32'd5;
        rs2_data = 32'd10;
        funct7 = 7'b0000000;     // FUNCT7 for SLT
        #10 check_output(32'd1, 1'b0); // Expected ALU result = 1 (rs1 < rs2), no branch
        $display("SLT Operation: rs1 = %0d, rs2 = %0d, alu_result = %0d", rs1_data, rs2_data, alu_result);

        // Test 4: SLTU (R-type, unsigned comparison)
        funct3 = 3'b011;         // SLTU
        rs1_data = 32'hFFFFFFFE; // -2 as unsigned
        rs2_data = 32'd10;
        #10 check_output(32'd0, 1'b0); // Expected ALU result = 0 (unsigned rs1 > rs2), no branch
        $display("SLTU Operation: rs1 = %h, rs2 = %h, alu_result = %0d", rs1_data, rs2_data, alu_result);

        // Test 5: ADDI (I-type)
        opcode = 7'b0010011;     // I-type
        funct3 = 3'b000;         // ADDI
        imm = 32'd15;
        rs1_data = 32'd10;
        #10 check_output(32'd25, 1'b0); // Expected ALU result = 25, no branch
        $display("ADDI Operation: rs1 = %0d, imm = %0d, alu_result = %0d", rs1_data, imm, alu_result);

        // Test 6: AND (R-type)
        opcode = 7'b0110011;     // R-type
        funct3 = 3'b111;         // AND
        rs1_data = 32'hF0F0F0F0;
        rs2_data = 32'h0F0F0F0F;
        #10 check_output(32'h00000000, 1'b0); // Expected ALU result = 0, no branch
        $display("AND Operation: rs1 = %h, rs2 = %h, alu_result = %h", rs1_data, rs2_data, alu_result);

        // Test 7: OR (R-type)
        funct3 = 3'b110;         // OR
        rs1_data = 32'hF0F0F0F0;
        rs2_data = 32'h0F0F0F0F;
        #10 check_output(32'hFFFFFFFF, 1'b0); // Expected ALU result = 0xFFFFFFFF, no branch
        $display("OR Operation: rs1 = %h, rs2 = %h, alu_result = %h", rs1_data, rs2_data, alu_result);

        // Test 8: XOR (R-type)
        funct3 = 3'b100;         // XOR
        rs1_data = 32'hAAAA5555;
        rs2_data = 32'h5555AAAA;
        #10 check_output(32'hFFFFFFFF, 1'b0); // Expected ALU result = 0xFFFFFFFF, no branch
        $display("XOR Operation: rs1 = %h, rs2 = %h, alu_result = %h", rs1_data, rs2_data, alu_result);

        // Test 9: SLL (R-type, Shift Left Logical)
        funct3 = 3'b001;         // SLL
        rs1_data = 32'd1;
        rs2_data = 32'd5;
        #10 check_output(32'd32, 1'b0); // Expected ALU result = 32, no branch
        $display("SLL Operation: rs1 = %0d, rs2 = %0d, alu_result = %0d", rs1_data, rs2_data, alu_result);

        // Test 10: BEQ (Branch, equal)
        opcode = 7'b1100011;     // B-type (BEQ)
        funct3 = 3'b000;         // BEQ
        rs1_data = 32'd30;
        rs2_data = 32'd30;
        #10 check_output(32'd0, 1'b1); // Branch taken
        $display("BEQ Operation: rs1 = %0d, rs2 = %0d, branch_taken = %b", rs1_data, rs2_data, branch_taken);

        // Test 11: BLT (Branch, less than)
        funct3 = 3'b100;         // BLT
        rs1_data = 32'd10;
        rs2_data = 32'd20;
        #10 check_output(32'd0, 1'b1); // Branch taken
        $display("BLT Operation: rs1 = %0d, rs2 = %0d, branch_taken = %b", rs1_data, rs2_data, branch_taken);

        // Test 12: LUI (U-type)
        opcode = 7'b0110111;     // LUI
        imm = 32'h1000;
        #10 check_output(32'h1000, 1'b0); // Expected ALU result = 0x1000, no branch
        $display("LUI Operation: imm = %h, alu_result = %h", imm, alu_result);

        // Test 13: AUIPC (U-type)
        opcode = 7'b0010111;     // AUIPC
        pc = 32'h2000;
        imm = 32'h1000;
        #10 check_output(32'h3000, 1'b0); // Expected ALU result = 0x3000, no branch
        $display("AUIPC Operation: pc = %h, imm = %h, alu_result = %h", pc, imm, alu_result);

        // Test 14: Invalid Instruction (should handle gracefully)
        opcode = 7'b1111111;     // Invalid opcode
        #10 check_output(32'h0, 1'b0); // Expected ALU result = 0, no branch
        $display("Invalid Operation: Handling invalid opcode gracefully.");

        // Test complete
        $display("ALU Test Bench Completed.");
        $finish;
    end
endmodule
