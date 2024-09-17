// instruction_decode_unit_tb.sv
// Testbench for the Instruction Decode Unit for RISC-V RV32I

`timescale 1ns / 1ps

module instruction_decode_unit_tb;

    // Inputs to the DUT (Device Under Test)
    logic [31:0] instruction;

    // Outputs from the DUT
    logic [6:0]  opcode;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [6:0]  funct7;
    logic [31:0] imm;
    logic [2:0]  instr_type;

    // Instantiate the DUT
    instruction_decode_unit dut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm(imm),
        .instr_type(instr_type)
    );

    // Instruction type constants
    localparam logic [2:0]
        R_TYPE       = 3'b000,
        I_TYPE       = 3'b001,
        S_TYPE       = 3'b010,
        B_TYPE       = 3'b011,
        U_TYPE       = 3'b100,
        J_TYPE       = 3'b101,
        UNKNOWN_TYPE = 3'b111;

    // Opcode constants for readability
    localparam logic [6:0]
        OPCODE_R_TYPE   = 7'b0110011,
        OPCODE_I_TYPE   = 7'b0010011,
        OPCODE_LOAD     = 7'b0000011,
        OPCODE_STORE    = 7'b0100011,
        OPCODE_BRANCH   = 7'b1100011,
        OPCODE_LUI      = 7'b0110111,
        OPCODE_AUIPC    = 7'b0010111,
        OPCODE_JAL      = 7'b1101111,
        OPCODE_JALR     = 7'b1100111;

    // Task to display results
    task display_results;
        $display("Time: %0t ns", $time);
        $display("Instruction: 0x%08X", instruction);
        $display("Opcode:      0x%02X", opcode);
        $display("rd:          %0d", rd);
        $display("funct3:      0x%01X", funct3);
        $display("rs1:         %0d", rs1);
        $display("rs2:         %0d", rs2);
        $display("funct7:      0x%02X", funct7);
        $display("imm:         0x%08X", imm);
        $display("instr_type:  %0d", instr_type);
        $display("--------------------------------------------");
    endtask

    // Test cases
    initial begin
        // Test Case 1: R-type Instruction (ADD x10, x11, x12)
        instruction = {7'b0000000, 5'd12, 5'd11, 3'b000, 5'd10, OPCODE_R_TYPE};
        #10;
        assert(opcode == OPCODE_R_TYPE) else $error("Opcode mismatch for R-type instruction.");
        assert(rd == 5'd10) else $error("rd mismatch for R-type instruction.");
        assert(funct3 == 3'b000) else $error("funct3 mismatch for R-type instruction.");
        assert(rs1 == 5'd11) else $error("rs1 mismatch for R-type instruction.");
        assert(rs2 == 5'd12) else $error("rs2 mismatch for R-type instruction.");
        assert(funct7 == 7'b0000000) else $error("funct7 mismatch for R-type instruction.");
        assert(instr_type == R_TYPE) else $error("Instruction type mismatch for R-type instruction.");
        assert(imm == 32'd0) else $error("Immediate value should be zero for R-type instruction.");
        display_results();

        // Test Case 2: I-type Instruction (ADDI x5, x6, -10)
        instruction = {{12'hFF6}, 5'd6, 3'b000, 5'd5, OPCODE_I_TYPE};
        #10;
        assert(opcode == OPCODE_I_TYPE) else $error("Opcode mismatch for I-type instruction.");
        assert(rd == 5'd5) else $error("rd mismatch for I-type instruction.");
        assert(funct3 == 3'b000) else $error("funct3 mismatch for I-type instruction.");
        assert(rs1 == 5'd6) else $error("rs1 mismatch for I-type instruction.");
        assert(rs2 == 5'd0) else $error("rs2 should be zero for I-type instruction.");
        assert(funct7 == 7'd0) else $error("funct7 should be zero for I-type instruction.");
        assert(instr_type == I_TYPE) else $error("Instruction type mismatch for I-type instruction.");
        assert(imm == 32'hFFFFFFF6) else $error("Immediate value mismatch for I-type instruction.");
        display_results();

        // Test Case 3: S-type Instruction (SW x15, 16(x14))
       instruction = {7'b0000010, 5'd15, 5'd14, 3'b010, 5'd0, OPCODE_STORE};
    #10;
    assert(opcode == OPCODE_STORE) else $error("Opcode mismatch for S-type instruction.");
    assert(funct3 == 3'b010) else $error("funct3 mismatch for S-type instruction.");
    assert(rs1 == 5'd14) else $error("rs1 mismatch for S-type instruction.");
    assert(rs2 == 5'd15) else $error("rs2 mismatch for S-type instruction.");
    assert(instr_type == S_TYPE) else $error("Instruction type mismatch for S-type instruction.");
    assert(imm == 32'd16) else $error("Immediate value mismatch for S-type instruction.");
    display_results();


        // End of Test Cases
        $display("All test cases completed.");
        $finish;
    end

endmodule
