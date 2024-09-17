module control_unit (
    input wire clk,
    input wire reset_n, // Added a reset input for better FSM initialization


    // Connection to IFU
    output wire fetch_en, // Tell IFU to search
    output wire fetch_address, // Where IFU should search

    input wire fetch_done, // IFU tell Control that its done
    input logic[31:0] instruction,  // instruction from IFU



    // Connection to IDU
    output logic [31:0] instruction, // Send Instruction to IDU
    input logic [2:0] instruction_type // Get back instruction type from IDU
    input logic [6:0]  opcode,      // 7-bit opcode field
    input logic [4:0]  rd,          // 5-bit destination register
    input logic [2:0]  funct3,      // 3-bit funct3 field
    input logic [4:0]  rs1,         // 5-bit source register 1
    input logic [4:0]  rs2,         // 5-bit source register 2
    input logic [6:0]  funct7,      // 7-bit funct7 field
    input logic [31:0] imm,         // 32-bit sign-extended immediate value
    input logic [2:0]  instr_type

    // Connection to CPU CSR
    // AXI connection to CSR, clocked
    
    output logic [4:0] rs1,
    output logic [4:0] rs2,

);

    typedef enum logic [2:0] { // Use [2:0] if you have 8 states (0 to 7)
        IDLE = 3'b000,
        FETCH = 3'b001,
        DECODE = 3'b010,
        EXECUTE = 3'b011,
        READ_REGISTER = 3'b100,
        WRITE_REGISTER = 3'b101,
        READ_MEMORY = 3'b110,
        WRITE_MEMORY = 3'b111
    } state_t;

    // State variables
    state_t current_state, next_state;

always_comb begin
    case (current_state)
        IDLE: begin
            next_state = FETCH;
        end
        FETCH: begin
            fetch_en = 1;
            if(fetch_done)
                next_state = DECODE;
                fetch_en = 0
        end
        DECODE: begin
            //conditionally move to next state based on decoded statement
            if(instr_type == 3'b000) begin
                next_state = READ_REGISTER
            end
            next_state = EXECUTE;
        end
        EXECUTE: begin
            next_state = READ_REGISTER;
        end
        READ_REGISTER: begin
            next_state = WRITE_REGISTER;
        end
        WRITE_REGISTER: begin
            next_state = READ_MEMORY;
        end
        READ_MEMORY: begin
            next_state = WRITE_MEMORY;
        end
        WRITE_MEMORY: begin
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end


    // Sequential logic to update current state
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE; // Reset state
        else
            current_state <= next_state;
    end

endmodule
