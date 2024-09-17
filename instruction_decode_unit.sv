// instruction_decode_unit.sv
// Instruction Decode Unit for RISC-V RV32I
// Decodes a 32-bit instruction into its constituent fields

`timescale 1ns / 1ps

module instruction_decode_unit (

    input  logic [31:0] instruction, // 32-bit instruction input
    output logic [6:0]  opcode,      // 7-bit opcode field
    output logic [4:0]  rd,          // 5-bit destination register
    output logic [2:0]  funct3,      // 3-bit funct3 field
    output logic [4:0]  rs1,         // 5-bit source register 1
    output logic [4:0]  rs2,         // 5-bit source register 2
    output logic [6:0]  funct7,      // 7-bit funct7 field
    output logic [31:0] imm,         // 32-bit sign-extended immediate value
    output logic [2:0]  instr_type   // Instruction type
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

assign opcode = instruction[6:0];

always_comb begin
    rd        = 5'd0;
    funct3    = 3'd0;
    rs1       = 5'd0;
    rs2       = 5'd0;
    funct7    = 7'd0;
    imm       = 32'd0;
    instr_type = 3'b111;

    case (opcode)
        OPCODE_R_TYPE: begin
            instr_type = R_TYPE;
            funct7 = instruction[31:25];
            rs2    = instruction[24:20];
            rs1    = instruction[19:15];
            funct3 = instruction[14:12];
            rd     = instruction[11:7];
        end

        OPCODE_I_TYPE: begin
            instr_type = I_TYPE;
            imm    = {{20{instruction[31]}}, instruction[31:20]};
            rs1    = instruction[19:15];
            funct3 = instruction[14:12];
            rd     = instruction[11:7];
        end

        OPCODE_LOAD: begin
            instr_type = L_TYPE;
            imm    = {{20{instruction[31]}}, instruction[31:20]};
            rs1    = instruction[19:15];
            funct3 = instruction[14:12];
            rd     = instruction[11:7];
        end

        OPCODE_STORE: begin
            instr_type = S_TYPE;
            imm    = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            rs2    = instruction[24:20];
            rs1    = instruction[19:15];
            funct3 = instruction[14:12];
        end

        OPCODE_BRANCH: begin
            instr_type = B_TYPE;
            imm = {{19{instruction[31]}}, instruction[31], instruction[7], 
                   instruction[30:25], instruction[11:8], 1'b0};
            rs2    = instruction[24:20];
            rs1    = instruction[19:15];
            funct3 = instruction[14:12];
        end

        OPCODE_LUI, OPCODE_AUIPC: begin
            instr_type = U_TYPE;
            imm = {instruction[31:12], 12'd0};
            rd  = instruction[11:7];
        end

        OPCODE_JAL: begin
            instr_type = J_TYPE;
            imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], 
                   instruction[20], instruction[30:21], 1'b0};
            rd  = instruction[11:7];
        end

        OPCODE_JALR: begin
            instr_type = I_TYPE;
            imm    = {{20{instruction[31]}}, instruction[31:20]};
            rs1    = instruction[19:15];
            funct3 = instruction[14:12];
            rd     = instruction[11:7];
        end

        default: begin
            instr_type = 3'b111;
        end
    endcase
end

endmodule
