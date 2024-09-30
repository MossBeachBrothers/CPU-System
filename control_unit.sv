//Control Unit Module : Takes in Decoded instruction, outputs control signal enables for modules
module control_unit (
    input  logic        clk,
    input  logic        reset_n,

    // Connection to IFU (Instruction Fetch Unit)
    output logic        fetch_enable,         // Enable instruction fetch
    input  logic        fetch_done,           // IFU signals fetch is done
    input  logic [31:0] instruction,          // Instruction fetched

    // Connection to IDU (Instruction Decode Unit)
    output logic        decode_enable,        // Enable instruction decode
    output logic [31:0] instruction_to_decode,// Instruction to IDU
    input  logic        decode_done,          // IDU signals decode is done
    input  logic [6:0]  opcode,               // Decoded opcode
    input  logic [4:0]  rd,                   // Decoded destination register
    input  logic [2:0]  funct3,               // Decoded funct3
    input  logic [4:0]  rs1,                  // Decoded source register 1
    input  logic [4:0]  rs2,                  // Decoded source register 2
    input  logic [6:0]  funct7,               // Decoded funct7
    input  logic [31:0] imm,                  // Decoded immediate
    input  logic [2:0]  instr_type,           // Instruction type

    // Connection to Register File
    output logic        reg_read_enable,      // Enable register read
    output logic        reg_write_enable,     // Enable register write
    output logic [4:0]  reg_rs1,              // Register read address 1
    output logic [4:0]  reg_rs2,              // Register read address 2
    output logic [4:0]  reg_rd,               // Register write address
    output logic [31:0] reg_write_data,       // Data to write to register
    input  logic [31:0] reg_read_data1,       // Data from register rs1
    input  logic [31:0] reg_read_data2,       // Data from register rs2
    input  logic        reg_read_data_valid,  // Register data valid
    input  logic        reg_write_done,       // Register write done

    // Connection to ALU
    output logic        alu_enable,           // Enable ALU
    output logic [31:0] alu_operand1,         // Operand 1 to ALU
    output logic [31:0] alu_operand2,         // Operand 2 to ALU
    input  logic        alu_done,             // ALU signals operation done
    input  logic [31:0] alu_result,           // ALU result

    // Connection to Memory Access Unit
    output logic        memory_read_enable,   // Enable memory read
    output logic        memory_write_enable,  // Enable memory write
    output logic [31:0] memory_address,       // Memory address
    output logic [31:0] memory_write_data,    // Data to write to memory
    input  logic [31:0] memory_read_data,     // Data read from memory
    input  logic        memory_read_data_valid,// Memory read data valid
    input  logic        memory_write_done     // Memory write done
);

    // Define FSM states
    typedef enum logic [2:0] {
        IDLE       = 3'd0,
        FETCH      = 3'd1,
        DECODE     = 3'd2,
        READ_REG   = 3'd3,
        EXECUTE    = 3'd4,
        MEM_READ   = 3'd5,
        MEM_WRITE  = 3'd6,
        WRITE_REG  = 3'd7
    } state_t;

    state_t current_state;

    // Registers to hold intermediate values
    logic [31:0] instruction_reg;

    logic [6:0] opcode_reg;
    logic [4:0] rd_reg;
    logic [4:0] rs1_reg;
    logic [4:0] rs2_reg;
    logic [31:0] imm_reg;
    logic [2:0] instr_type_reg;

    logic [31:0] reg_read_data1_reg;
    logic [31:0] reg_read_data2_reg;

    logic [31:0] alu_result_reg;

    // Sequential logic for state transitions and capturing signals
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;

            // Reset all registers
            instruction_reg <= 32'd0;

            opcode_reg <= 7'd0;
            rd_reg <= 5'd0;
            rs1_reg <= 5'd0;
            rs2_reg <= 5'd0;
            imm_reg <= 32'd0;
            instr_type_reg <= 3'd0;

            reg_read_data1_reg <= 32'd0;
            reg_read_data2_reg <= 32'd0;

            alu_result_reg <= 32'd0;
        end else begin
            // State transition logic
            case (current_state)
                IDLE: begin
                    current_state <= FETCH;
                end
                FETCH: begin
                    if (fetch_done) begin
                        instruction_reg <= instruction;
                        current_state <= DECODE;
                    end
                end
                DECODE: begin
                    if (decode_done) begin
                        opcode_reg <= opcode;
                        rd_reg <= rd;
                        rs1_reg <= rs1;
                        rs2_reg <= rs2;
                        imm_reg <= imm;
                        instr_type_reg <= instr_type;
                        current_state <= READ_REG;
                    end
                end
                READ_REG: begin
                    if (reg_read_data_valid) begin
                        reg_read_data1_reg <= reg_read_data1;
                        reg_read_data2_reg <= reg_read_data2;
                        current_state <= EXECUTE;
                    end
                end
                EXECUTE: begin
                    if (alu_done) begin
                        alu_result_reg <= alu_result;
                        if (opcode_reg == 7'b0000011) // LW
                            current_state <= MEM_READ;
                        else if (opcode_reg == 7'b0100011) // SW
                            current_state <= MEM_WRITE;
                        else
                            current_state <= WRITE_REG;
                    end
                end
                MEM_READ: begin
                    if (memory_read_data_valid)
                        current_state <= WRITE_REG;
                end
                MEM_WRITE: begin
                    if (memory_write_done)
                        current_state <= FETCH;
                end
                WRITE_REG: begin
                    if (reg_write_done)
                        current_state <= FETCH;
                end
                default: begin
                    current_state <= IDLE;
                end
            endcase
        end
    end

    // Output logic
    always_comb begin
        // Default values
        fetch_enable = 1'b0;
        decode_enable = 1'b0;
        reg_read_enable = 1'b0;
        alu_enable = 1'b0;
        memory_read_enable = 1'b0;
        memory_write_enable = 1'b0;
        reg_write_enable = 1'b0;

        instruction_to_decode = instruction_reg;

        reg_rs1 = 5'd0;
        reg_rs2 = 5'd0;
        reg_rd = 5'd0;
        reg_write_data = 32'd0;
        alu_operand1 = 32'd0;
        alu_operand2 = 32'd0;
        memory_address = 32'd0;
        memory_write_data = 32'd0;

        case (current_state)
            FETCH: begin
                fetch_enable = 1'b1;
            end
            DECODE: begin
                decode_enable = 1'b1;
                instruction_to_decode = instruction_reg;
            end
            READ_REG: begin
                reg_read_enable = 1'b1;
                reg_rs1 = rs1_reg;
                reg_rs2 = rs2_reg;
            end
            EXECUTE: begin
                alu_enable = 1'b1;
                alu_operand1 = reg_read_data1_reg;
                if (instr_type_reg == 3'b001) begin // I-type
                    alu_operand2 = imm_reg;
                end else if (instr_type_reg == 3'b000) begin // R-type
                    alu_operand2 = reg_read_data2_reg;
                end else if (instr_type_reg == 3'b010) begin // S-type
                    alu_operand2 = imm_reg;
                end else begin
                    alu_operand2 = 32'd0;
                end
            end
            MEM_READ: begin
                memory_read_enable = 1'b1;
                memory_address = alu_result_reg;
            end
            MEM_WRITE: begin
                memory_write_enable = 1'b1;
                memory_address = alu_result_reg;
                memory_write_data = reg_read_data2_reg;
            end
            WRITE_REG: begin
                reg_write_enable = 1'b1;
                reg_rd = rd_reg;
                if (opcode_reg == 7'b0000011) begin // LW
                    reg_write_data = memory_read_data;
                end else begin
                    reg_write_data = alu_result_reg;
                end
            end
            default: begin
                // Do nothing
            end
        endcase
    end

endmodule
