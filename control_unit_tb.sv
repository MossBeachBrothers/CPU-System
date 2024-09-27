`timescale 1ns/1ps

module control_unit_tb;

    // Clock and reset signals
    logic clk;
    logic reset_n;

    // Signals connected to the control_unit
    // IFU (Instruction Fetch Unit) signals
    logic        fetch_enable;         
    logic        fetch_done;           
    logic [31:0] instruction;          
    // IDU (Instruction Decode Unit) signals
    logic        decode_enable;        
    logic [31:0] instruction_to_decode;
    logic        decode_done;          
    logic [6:0]  opcode;               
    logic [4:0]  rd;                   
    logic [2:0]  funct3;               
    logic [4:0]  rs1;                  
    logic [4:0]  rs2;                  
    logic [6:0]  funct7;               
    logic [31:0] imm;                  
    logic [2:0]  instr_type;           

    // Register File signals
    logic        reg_read_enable;      
    logic        reg_write_enable;     
    logic [4:0]  reg_rs1;              
    logic [4:0]  reg_rs2;              
    logic [4:0]  reg_rd;               
    logic [31:0] reg_write_data;       
    logic [31:0] reg_read_data1;       
    logic [31:0] reg_read_data2;       
    logic        reg_read_data_valid;  
    logic        reg_write_done;       

    // ALU signals
    logic        alu_enable;           
    logic [31:0] alu_operand1;         
    logic [31:0] alu_operand2;         
    logic        alu_done;             
    logic [31:0] alu_result;           

    // Memory Access Unit signals
    logic        memory_read_enable;    
    logic        memory_write_enable;   
    logic [31:0] memory_address;        
    logic [31:0] memory_write_data;     
    logic [31:0] memory_read_data;      
    logic        memory_read_data_valid;
    logic        memory_write_done;     

    // Instantiate the control_unit module
    control_unit uut (
        .clk(clk),
        .reset_n(reset_n),

        // IFU signals
        .fetch_enable(fetch_enable),
        .fetch_done(fetch_done),
        .instruction(instruction),

        // IDU signals
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

        // Register File signals
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

        // ALU signals
        .alu_enable(alu_enable),
        .alu_operand1(alu_operand1),
        .alu_operand2(alu_operand2),
        .alu_done(alu_done),
        .alu_result(alu_result),

        // Memory Access Unit signals
        .memory_read_enable(memory_read_enable),
        .memory_write_enable(memory_write_enable),
        .memory_address(memory_address),
        .memory_write_data(memory_write_data),
        .memory_read_data(memory_read_data),
        .memory_read_data_valid(memory_read_data_valid),
        .memory_write_done(memory_write_done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end

    // Reset sequence
    initial begin
        reset_n = 0;
        #15;
        reset_n = 1;
    end

    // Test sequence
    initial begin
        // Wait for reset to complete
        @(posedge reset_n);

        // Initialize signals
        fetch_done = 0;
        instruction = 32'b0;
        decode_done = 0;
        opcode = 7'b0;
        rd = 5'b0;
        funct3 = 3'b0;
        rs1 = 5'b0;
        rs2 = 5'b0;
        funct7 = 7'b0;
        imm = 32'b0;
        instr_type = 3'b0;
        reg_read_data1 = 32'b0;
        reg_read_data2 = 32'b0;
        reg_read_data_valid = 0;
        reg_write_done = 0;
        alu_done = 0;
        alu_result = 32'b0;
        memory_read_data = 32'b0;
        memory_read_data_valid = 0;
        memory_write_done = 0;

        // ********** First Instruction: ADDI x1, x0, 5 **********
        $display("Starting test for ADDI x1, x0, 5");

        // Wait for fetch_enable to be asserted
        wait(fetch_enable);

        // Simulate instruction fetch
        @(posedge clk);
        instruction = 32'h00500093;  // ADDI x1, x0, 5
        fetch_done = 1;

        @(posedge clk);
        fetch_done = 0;

        $display("Instruction fetched: ADDI x1, x0, 5");

        // Wait for decode_enable to be asserted
        wait(decode_enable);

        // Provide instruction to decode
        @(posedge clk);
        instruction_to_decode = instruction;
        decode_done = 1;
        opcode = 7'b0010011;  // ADDI opcode
        rd = 5'd1;            // Destination register x1
        funct3 = 3'b000;
        rs1 = 5'd0;           // Source register x0
        imm = 32'd5;          // Immediate value 5
        instr_type = 3'b001;  // I-type instruction

        @(posedge clk);
        decode_done = 0;

        $display("Instruction decoded: ADDI x1, x0, 5");

        // Wait for reg_read_enable to be asserted
        wait(reg_read_enable);

        // Simulate register read
        @(posedge clk);
        reg_read_data1 = 32'd0;  // x0 always contains 0
        reg_read_data_valid = 1;

        @(posedge clk);
        reg_read_data_valid = 0;

        $display("Register read completed for ADDI instruction");

        // Wait for alu_enable to be asserted
        wait(alu_enable);

        // Simulate ALU operation
        @(posedge clk);
        alu_result = alu_operand1 + alu_operand2;  // 0 + 5 = 5
        alu_done = 1;

        @(posedge clk);
        alu_done = 0;

        $display("ALU operation completed for ADDI instruction");

        // Wait for reg_write_enable to be asserted
        wait(reg_write_enable);

        // Simulate register write done
        @(posedge clk);
        reg_write_done = 1;

        @(posedge clk);
        reg_write_done = 0;

        $display("Register write completed for ADDI instruction");

        // ********** Second Instruction: LW x2, 0(x1) **********
        $display("Starting test for LW x2, 0(x1)");

        // Wait for fetch_enable to be asserted
        wait(fetch_enable);

        // Simulate instruction fetch
        @(posedge clk);
        instruction = 32'h0000A083;  // LW x2, 0(x1)
        fetch_done = 1;

        @(posedge clk);
        fetch_done = 0;

        $display("Instruction fetched: LW x2, 0(x1)");

        // Wait for decode_enable to be asserted
        wait(decode_enable);

        // Provide instruction to decode
        @(posedge clk);
        instruction_to_decode = instruction;
        decode_done = 1;
        opcode = 7'b0000011;  // LW opcode
        rd = 5'd2;            // Destination register x2
        funct3 = 3'b010;
        rs1 = 5'd1;           // Source register x1
        imm = 32'd0;          // Immediate value 0
        instr_type = 3'b001;  // I-type instruction

        @(posedge clk);
        decode_done = 0;

        $display("Instruction decoded: LW x2, 0(x1)");

        // Wait for reg_read_enable to be asserted
        wait(reg_read_enable);

        // Simulate register read
        @(posedge clk);
        reg_read_data1 = 32'd5;  // Value of x1
        reg_read_data_valid = 1;

        @(posedge clk);
        reg_read_data_valid = 0;

        $display("Register read completed for LW instruction");

        // Wait for alu_enable to be asserted
        wait(alu_enable);

        // Simulate ALU operation
        @(posedge clk);
        alu_result = alu_operand1 + alu_operand2;  // 5 + 0 = 5
        alu_done = 1;

        @(posedge clk);
        alu_done = 0;

        $display("ALU operation completed for LW instruction");

        // Wait for memory_read_enable to be asserted
        wait(memory_read_enable);

        // Simulate memory read
        @(posedge clk);
        memory_read_data = 32'd100;  // Data at memory address 5
        memory_read_data_valid = 1;

        @(posedge clk);
        memory_read_data_valid = 0;

        $display("Memory read completed for LW instruction");

        // Wait for reg_write_enable to be asserted
        wait(reg_write_enable);

        // Simulate register write done
        @(posedge clk);
        reg_write_done = 1;

        @(posedge clk);
        reg_write_done = 0;

        $display("Register write completed for LW instruction");

        // ********** Third Instruction: SW x2, 0(x1) **********
        $display("Starting test for SW x2, 0(x1)");

        // Wait for fetch_enable to be asserted
        wait(fetch_enable);

        // Simulate instruction fetch
        @(posedge clk);
        instruction = 32'h0020A023;  // SW x2, 0(x1)
        fetch_done = 1;

        @(posedge clk);
        fetch_done = 0;

        $display("Instruction fetched: SW x2, 0(x1)");

        // Wait for decode_enable to be asserted
        wait(decode_enable);

        // Provide instruction to decode
        @(posedge clk);
        instruction_to_decode = instruction;
        decode_done = 1;
        opcode = 7'b0100011;  // SW opcode
        funct3 = 3'b010;
        rs1 = 5'd1;           // Base address register x1
        rs2 = 5'd2;           // Source register x2
        imm = 32'd0;          // Immediate value 0
        instr_type = 3'b010;  // S-type instruction

        @(posedge clk);
        decode_done = 0;

        $display("Instruction decoded: SW x2, 0(x1)");

        // Wait for reg_read_enable to be asserted
        wait(reg_read_enable);

        // Simulate register read
        @(posedge clk);
        reg_read_data1 = 32'd5;    // Value of x1
        reg_read_data2 = 32'd100;  // Value of x2
        reg_read_data_valid = 1;

        @(posedge clk);
        reg_read_data_valid = 0;

        $display("Register read completed for SW instruction");

        // Wait for alu_enable to be asserted
        wait(alu_enable);

        // Simulate ALU operation
        @(posedge clk);
        alu_result = alu_operand1 + alu_operand2;  // 5 + 0 = 5
        alu_done = 1;

        @(posedge clk);
        alu_done = 0;

        $display("ALU operation completed for SW instruction");

        // Wait for memory_write_enable to be asserted
        wait(memory_write_enable);

        // Simulate memory write done
        @(posedge clk);
        memory_write_done = 1;

        @(posedge clk);
        memory_write_done = 0;

        $display("Memory write completed for SW instruction");

        // End of test
        $display("Test completed successfully");
        $finish;
    end

    // Monitor and debug messages
    always @(posedge clk) begin
        if (reset_n) begin
            $display("Time %t: fetch_enable=%b, decode_enable=%b, reg_read_enable=%b, alu_enable=%b, memory_read_enable=%b, memory_write_enable=%b, reg_write_enable=%b",
                     $time, fetch_enable, decode_enable, reg_read_enable, alu_enable, memory_read_enable, memory_write_enable, reg_write_enable);
        end
    end

endmodule
