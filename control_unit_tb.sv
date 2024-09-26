// control_unit_tb.sv
// Testbench for the control_unit module

`timescale 1ns/1ps

module control_unit_tb;

    // Clock and reset signals
    logic clk;
    logic reset_n;

    // Inputs to the control_unit (regs)
    logic        fetch_done;
    logic [31:0] instruction;
    logic        instruction_valid;

    logic        decode_done;
    logic [6:0]  opcode;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [6:0]  funct7;
    logic [31:0] imm;
    logic [2:0]  instr_type;

    logic [31:0] reg_read_data1;
    logic [31:0] reg_read_data2;
    logic        reg_read_data_valid;
    logic        reg_write_done;

    logic        alu_done;
    logic [31:0] alu_result;

    logic [31:0] memory_read_data;
    logic        memory_read_data_valid;
    logic        memory_write_done;

    // Outputs from the control_unit (wires)
    logic        fetch_enable;
    logic        decode_enable;
    logic [31:0] instruction_to_decode;

    logic        reg_read_enable;
    logic        reg_write_enable;
    logic [4:0]  reg_rs1;
    logic [4:0]  reg_rs2;
    logic [4:0]  reg_rd;
    logic [31:0] reg_write_data;

    logic        alu_enable;
    logic [31:0] alu_operand1;
    logic [31:0] alu_operand2;

    logic        memory_read_enable;
    logic        memory_write_enable;
    logic [31:0] memory_address;
    logic [31:0] memory_write_data;

    // Instantiate the control_unit module
    control_unit dut (
        .clk(clk),
        .reset_n(reset_n),

        // Connection to IFU
        .fetch_enable(fetch_enable),
        .fetch_done(fetch_done),
        .instruction(instruction),
        .instruction_valid(instruction_valid),

        // Connection to IDU
        .decode_enable(decode_enable),
        .instruction_to_decode(instruction_to_decode),
        .decode_done(decode_done),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm(imm),
        .instr_type(instr_type),

        // Connection to Register File
        .reg_read_enable(reg_read_enable),
        .reg_write_enable(reg_write_enable),
        .reg_rs1(reg_rs1),
        .reg_rs2(reg_rs2),
        .reg_rd(reg_rd),
        .reg_write_data(reg_write_data),
        .reg_read_data1(reg_read_data1),
        .reg_read_data2(reg_read_data2),
        .reg_read_data_valid(reg_read_data_valid),
        .reg_write_done(reg_write_done),

        // Connection to ALU
        .alu_enable(alu_enable),
        .alu_operand1(alu_operand1),
        .alu_operand2(alu_operand2),
        .alu_done(alu_done),
        .alu_result(alu_result),

        // Connection to Memory Access Unit
        .memory_read_enable(memory_read_enable),
        .memory_write_enable(memory_write_enable),
        .memory_address(memory_address),
        .memory_write_data(memory_write_data),
        .memory_read_data(memory_read_data),
        .memory_read_data_valid(memory_read_data_valid),
        .memory_write_done(memory_write_done)
    );

    // Clock generation (100MHz clock)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        reset_n                = 0;
        fetch_done             = 0;
        instruction            = 0;
        instruction_valid      = 0;
        decode_done            = 0;
        opcode                 = 0;
        rd                     = 0;
        funct3                 = 0;
        rs1                    = 0;
        rs2                    = 0;
        funct7                 = 0;
        imm                    = 0;
        instr_type             = 0;
        reg_read_data1         = 0;
        reg_read_data2         = 0;
        reg_read_data_valid    = 0;
        reg_write_done         = 0;
        alu_done               = 0;
        alu_result             = 0;
        memory_read_data       = 0;
        memory_read_data_valid = 0;
        memory_write_done      = 0;

        // Wait for a few clock cycles
        #20;

        // Deassert reset
        reset_n = 1;

        // -------------------------
        // First Instruction: ADDI x1, x0, 100
        // -------------------------
        $display("\n--- Executing ADDI x1, x0, 100 ---");

        // Wait for FETCH state
        @(posedge clk);
        wait (fetch_enable == 1);
        $display("FETCH stage: fetch_enable asserted");

        // Simulate fetch done and instruction valid
        #10;
        fetch_done        = 1;
        instruction_valid = 1;
        instruction       = 32'h06400093; // Opcode for ADDI x1, x0, 100

        @(posedge clk);
        fetch_done        = 0;
        instruction_valid = 0;

        // Wait for DECODE state
        @(posedge clk);
        wait (decode_enable == 1);
        $display("DECODE stage: decode_enable asserted");

        // Simulate decode done with decoded fields
        #10;
        decode_done = 1;
        opcode      = 7'b0010011; // I-Type opcode
        rd          = 5'd1;
        funct3      = 3'b000;
        rs1         = 5'd0;
        rs2         = 5'd0;
        funct7      = 7'b0;
        imm         = 32'd100;
        instr_type  = 3'b001;     // I_TYPE

        @(posedge clk);
        decode_done = 0;

        // Wait for READ_REGISTER state
        @(posedge clk);
        wait (reg_read_enable == 1);
        $display("READ_REGISTER stage: reg_read_enable asserted");

        // Simulate register read data valid
        #10;
        reg_read_data_valid = 1;
        reg_read_data1      = 32'd0; // x0 = 0
        reg_read_data2      = 32'd0;

        @(posedge clk);
        reg_read_data_valid = 0;

        // Wait for EXECUTE state
        @(posedge clk);
        wait (alu_enable == 1);
        $display("EXECUTE stage: alu_enable asserted");

        // Simulate ALU operation done
        #10;
        alu_done   = 1;
        alu_result = reg_read_data1 + imm; // 0 + 100

        @(posedge clk);
        alu_done = 0;

        // Wait for WRITE_BACK state
        @(posedge clk);
        wait (reg_write_enable == 1);
        $display("WRITE_BACK stage: reg_write_enable asserted");

        // Simulate register write done
        #10;
        reg_write_done = 1;

        @(posedge clk);
        reg_write_done = 0;

        // -------------------------
        // Second Instruction: ADD x3, x1, x1
        // -------------------------
        $display("\n--- Executing ADD x3, x1, x1 ---");

        // Wait for FETCH state
        @(posedge clk);
        wait (fetch_enable == 1);
        $display("FETCH stage: fetch_enable asserted");

        // Simulate fetch done and instruction valid
        #10;
        fetch_done        = 1;
        instruction_valid = 1;
        instruction       = 32'h001081B3; // Opcode for ADD x3, x1, x1

        @(posedge clk);
        fetch_done        = 0;
        instruction_valid = 0;

        // Wait for DECODE state
        @(posedge clk);
        wait (decode_enable == 1);
        $display("DECODE stage: decode_enable asserted");

        // Simulate decode done with decoded fields
        #10;
        decode_done = 1;
        opcode      = 7'b0110011; // R-Type opcode
        rd          = 5'd3;
        funct3      = 3'b000;
        rs1         = 5'd1;
        rs2         = 5'd1;
        funct7      = 7'b0000000;
        imm         = 32'd0;
        instr_type  = 3'b000;     // R_TYPE

        @(posedge clk);
        decode_done = 0;

        // Wait for READ_REGISTER state
        @(posedge clk);
        wait (reg_read_enable == 1);
        $display("READ_REGISTER stage: reg_read_enable asserted");

        // Simulate register read data valid
        #10;
        reg_read_data_valid = 1;
        reg_read_data1      = 32'd100; // x1 = 100
        reg_read_data2      = 32'd100; // x1 = 100

        @(posedge clk);
        reg_read_data_valid = 0;

        // Wait for EXECUTE state
        @(posedge clk);
        wait (alu_enable == 1);
        $display("EXECUTE stage: alu_enable asserted");

        // Simulate ALU operation done
        #10;
        alu_done   = 1;
        alu_result = reg_read_data1 + reg_read_data2; // 100 + 100

        @(posedge clk);
        alu_done = 0;

        // Wait for WRITE_BACK state
        @(posedge clk);
        wait (reg_write_enable == 1);
        $display("WRITE_BACK stage: reg_write_enable asserted");

        // Simulate register write done
        #10;
        reg_write_done = 1;

        @(posedge clk);
        reg_write_done = 0;

        // -------------------------
        // Third Instruction: LW x4, 0(x3)
        // -------------------------
        $display("\n--- Executing LW x4, 0(x3) ---");

        // Wait for FETCH state
        @(posedge clk);
        wait (fetch_enable == 1);
        $display("FETCH stage: fetch_enable asserted");

        // Simulate fetch done and instruction valid
        #10;
        fetch_done        = 1;
        instruction_valid = 1;
        instruction       = 32'h0001A203; // Opcode for LW x4, 0(x3)

        @(posedge clk);
        fetch_done        = 0;
        instruction_valid = 0;

        // Wait for DECODE state
        @(posedge clk);
        wait (decode_enable == 1);
        $display("DECODE stage: decode_enable asserted");

        // Simulate decode done with decoded fields
        #10;
        decode_done = 1;
        opcode      = 7'b0000011; // Load opcode
        rd          = 5'd4;
        funct3      = 3'b010;
        rs1         = 5'd3;
        rs2         = 5'd0;
        funct7      = 7'b0;
        imm         = 32'd0;
        instr_type  = 3'b010;     // LOAD_TYPE

        @(posedge clk);
        decode_done = 0;

        // Wait for READ_REGISTER state
        @(posedge clk);
        wait (reg_read_enable == 1);
        $display("READ_REGISTER stage: reg_read_enable asserted");

        // Simulate register read data valid
        #10;
        reg_read_data_valid = 1;
        reg_read_data1      = 32'd200; // x3 = 200
        reg_read_data2      = 32'd0;

        @(posedge clk);
        reg_read_data_valid = 0;

        // Wait for EXECUTE state
        @(posedge clk);
        wait (alu_enable == 1);
        $display("EXECUTE stage: alu_enable asserted");

        // Simulate ALU operation done
        #10;
        alu_done   = 1;
        alu_result = reg_read_data1 + imm; // 200 + 0

        @(posedge clk);
        alu_done = 0;

        // Wait for MEMORY_ACCESS state
        @(posedge clk);
        wait (memory_read_enable == 1);
        $display("MEMORY_ACCESS stage: memory_read_enable asserted");

        // Simulate memory read data valid
        #10;
        memory_read_data_valid = 1;
        memory_read_data       = 32'd12345; // Data from memory

        @(posedge clk);
        memory_read_data_valid = 0;

        // Wait for WRITE_BACK state
        @(posedge clk);
        wait (reg_write_enable == 1);
        $display("WRITE_BACK stage: reg_write_enable asserted");

        // Simulate register write done
        #10;
        reg_write_done = 1;

        @(posedge clk);
        reg_write_done = 0;

        // -------------------------
        // Fourth Instruction: SW x4, 4(x3)
        // -------------------------
        $display("\n--- Executing SW x4, 4(x3) ---");

        // Wait for FETCH state
        @(posedge clk);
        wait (fetch_enable == 1);
        $display("FETCH stage: fetch_enable asserted");

        // Simulate fetch done and instruction valid
        #10;
        fetch_done        = 1;
        instruction_valid = 1;
        instruction       = 32'h0041A023; // Opcode for SW x4, 4(x3)

        @(posedge clk);
        fetch_done        = 0;
        instruction_valid = 0;

        // Wait for DECODE state
        @(posedge clk);
        wait (decode_enable == 1);
        $display("DECODE stage: decode_enable asserted");

        // Simulate decode done with decoded fields
        #10;
        decode_done = 1;
        opcode      = 7'b0100011; // Store opcode
        rd          = 5'd0;       // No destination register
        funct3      = 3'b010;
        rs1         = 5'd3;
        rs2         = 5'd4;
        funct7      = 7'b0;
        imm         = 32'd4;
        instr_type  = 3'b011;     // STORE_TYPE

        @(posedge clk);
        decode_done = 0;

        // Wait for READ_REGISTER state
        @(posedge clk);
        wait (reg_read_enable == 1);
        $display("READ_REGISTER stage: reg_read_enable asserted");

        // Simulate register read data valid
        #10;
        reg_read_data_valid = 1;
        reg_read_data1      = 32'd200;   // x3 = 200
        reg_read_data2      = 32'd12345; // x4 = 12345

        @(posedge clk);
        reg_read_data_valid = 0;

        // Wait for EXECUTE state
        @(posedge clk);
        wait (alu_enable == 1);
        $display("EXECUTE stage: alu_enable asserted");

        // Simulate ALU operation done
        #10;
        alu_done   = 1;
        alu_result = reg_read_data1 + imm; // 200 + 4

        @(posedge clk);
        alu_done = 0;

        // Wait for MEMORY_ACCESS state
        @(posedge clk);
        wait (memory_write_enable == 1);
        $display("MEMORY_ACCESS stage: memory_write_enable asserted");

        // Simulate memory write done
        #10;
        memory_write_done = 1;

        @(posedge clk);
        memory_write_done = 0;

        // Finish simulation
        #100;
        $display("\nSimulation completed successfully.");
        $finish;
    end

    // Monitor outputs and display state transitions
    always @(posedge clk) begin
        if (fetch_enable)
            $display("[Time %0t] FETCH: fetch_enable asserted", $time);
        if (decode_enable)
            $display("[Time %0t] DECODE: decode_enable asserted", $time);
        if (reg_read_enable)
            $display("[Time %0t] READ_REGISTER: reg_read_enable asserted", $time);
        if (alu_enable)
            $display("[Time %0t] EXECUTE: alu_enable asserted", $time);
        if (memory_read_enable)
            $display("[Time %0t] MEMORY_ACCESS: memory_read_enable asserted", $time);
        if (memory_write_enable)
            $display("[Time %0t] MEMORY_ACCESS: memory_write_enable asserted", $time);
        if (reg_write_enable)
            $display("[Time %0t] WRITE_BACK: reg_write_enable asserted", $time);
    end

endmodule
