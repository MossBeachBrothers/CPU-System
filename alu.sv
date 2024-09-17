`timescale 1ns / 1ps

module alu (
    // Inputs from the instruction decode unit
    input  logic [6:0]  opcode,      // Opcode field
    input  logic [4:0]  rd,          // Destination register address
    input  logic [2:0]  funct3,      // Funct3 field
    input  logic [4:0]  rs1_addr,    // Source register 1 address
    input  logic [4:0]  rs2_addr,    // Source register 2 address
    input  logic [6:0]  funct7,      // Funct7 field
    input  logic [31:0] imm,         // Immediate value
    input  logic [2:0]  instr_type,  // Instruction type
    input  logic [31:0] pc,          // Program Counter

    // Inputs from the register file
    input  logic [31:0] rs1_data,    // Data from source register 1
    input  logic [31:0] rs2_data,    // Data from source register 2

    // Outputs
    output logic [31:0] alu_result,  // ALU result (Effective address)
    output logic        branch_taken // Branch condition flag
);

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

localparam logic [2:0]
    R_TYPE = 3'b000,
    I_TYPE = 3'b001,
    S_TYPE = 3'b010,
    B_TYPE = 3'b011,
    U_TYPE = 3'b100,
    J_TYPE = 3'b101,
    L_TYPE = 3'b110;

localparam logic [6:0]
    FUNCT7_ADD  = 7'b0000000,
    FUNCT7_SUB  = 7'b0100000;

    // Internal signals for operands and ALU operation
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic        comparison_result;

    // ALU operation
    always_comb begin
        // Default outputs
        alu_result       = 32'd0;
        comparison_result = 1'b0;
        branch_taken     = 1'b0;

        // Default operands
        operand_a = rs1_data;
        operand_b = rs2_data;

        case (opcode)
            // R-type Instructions
            OPCODE_R_TYPE: begin
                case (funct3)
                    3'b000: begin // ADD or SUB
                        if (funct7 == FUNCT7_SUB)
                            alu_result = operand_a - operand_b; // SUB
                        else
                            alu_result = operand_a + operand_b; // ADD
                    end
                    3'b001: alu_result = operand_a << operand_b[4:0]; // SLL
                    3'b010: alu_result = ($signed(operand_a) < $signed(operand_b)) ? 1 : 0; // SLT
                    3'b011: alu_result = (operand_a < operand_b) ? 1 : 0; // SLTU
                    3'b100: alu_result = operand_a ^ operand_b; // XOR
                    3'b101: begin // SRL or SRA
                        if (funct7 == FUNCT7_SUB)
                            alu_result = $signed(operand_a) >>> operand_b[4:0]; // SRA
                        else
                            alu_result = operand_a >> operand_b[4:0]; // SRL
                    end
                    3'b110: alu_result = operand_a | operand_b; // OR
                    3'b111: alu_result = operand_a & operand_b; // AND
                    default: alu_result = 32'd0;
                endcase
            end

            // I-type Instructions
            OPCODE_I_TYPE: begin
                operand_a = rs1_data;
                operand_b = imm; // Immediate value
                case (funct3)
                    3'b000: alu_result = operand_a + operand_b; // ADDI
                    3'b001: alu_result = operand_a << operand_b[4:0]; // SLLI
                    3'b010: alu_result = ($signed(operand_a) < $signed(operand_b)) ? 1 : 0; // SLTI
                    3'b011: alu_result = (operand_a < operand_b) ? 1 : 0; // SLTIU
                    3'b100: alu_result = operand_a ^ operand_b; // XORI
                    3'b101: begin // SRLI or SRAI
                        if (funct7 == 7'b0000000)
                            alu_result = operand_a >> operand_b[4:0]; // SRLI
                        else if (funct7 == 7'b0100000)
                            alu_result = $signed(operand_a) >>> operand_b[4:0]; // SRAI
                    end
                    3'b110: alu_result = operand_a | operand_b; // ORI
                    3'b111: alu_result = operand_a & operand_b; // ANDI
                    default: alu_result = 32'd0;
                endcase
            end

            // S-type Instructions (Stores)
            OPCODE_STORE: begin
                operand_a = rs1_data;
                operand_b = imm;
                alu_result = operand_a + operand_b; // Effective address calculation for store
            end

            // B-type Instructions (Branches)
            OPCODE_BRANCH: begin
                operand_a = rs1_data;
                operand_b = rs2_data;
                case (funct3)
                    3'b000: comparison_result = (operand_a == operand_b); // BEQ
                    3'b001: comparison_result = (operand_a != operand_b); // BNE
                    3'b100: comparison_result = ($signed(operand_a) < $signed(operand_b)); // BLT
                    3'b101: comparison_result = ($signed(operand_a) >= $signed(operand_b)); // BGE
                    3'b110: comparison_result = (operand_a < operand_b); // BLTU
                    3'b111: comparison_result = (operand_a >= operand_b); // BGEU
                    default: comparison_result = 1'b0;
                endcase
                branch_taken = comparison_result;
            end

            // U-type Instructions (LUI, AUIPC)
            OPCODE_LUI: alu_result = imm; // Load Upper Immediate
            OPCODE_AUIPC: alu_result = pc + imm; // Add Upper Immediate to PC

            // J-type Instructions (JAL, JALR)
            OPCODE_JAL: alu_result = pc + 4; // Return address for JAL
            OPCODE_JALR: begin
                alu_result = pc + 4; // Return address for JALR
            end

            // **Load Instructions (LW, LH, LB, etc.)**
            OPCODE_LOAD: begin
                operand_a = rs1_data;
                operand_b = imm;
                alu_result = operand_a + operand_b; // Calculate effective address
            end

            // Default case
            default: begin
                alu_result = 32'd0;
                branch_taken = 1'b0;
            end
        endcase
    end
endmodule
