module control_unit (
    input  logic        clk,
    input  logic        reset_n,

    // Connection to IFU (Instruction Fetch Unit)
    output logic        fetch_enable,         // Enable instruction fetch
    input  logic        fetch_done,           // IFU signals fetch is done
    input  logic [31:0] instruction,          // Instruction fetched
    input  logic        instruction_valid,    // Instruction is valid

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

    // State definitions
    typedef enum logic [2:0] {
        IDLE           = 3'b000,
        FETCH          = 3'b001,
        DECODE         = 3'b010,
        READ_REGISTER  = 3'b011,
        EXECUTE        = 3'b100,
        MEMORY_ACCESS  = 3'b101,
        WRITE_BACK     = 3'b110
    } state_t;

    // Instruction type definitions
    localparam [2:0] R_TYPE    = 3'b000,
                     I_TYPE    = 3'b001,
                     LOAD_TYPE = 3'b010,
                     STORE_TYPE= 3'b011;

    // State variables
    state_t current_state, next_state;

    // Sequential logic to update current state
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Combinational logic for next state and outputs
    always_comb begin
        // Default assignments to prevent latches
        next_state = current_state;

        // Default outputs
        fetch_enable       = 0;
        decode_enable      = 0;
        reg_read_enable    = 0;
        reg_write_enable   = 0;
        alu_enable         = 0;
        memory_read_enable = 0;
        memory_write_enable= 0;

        // Default values for other outputs
        instruction_to_decode = 32'b0;
        reg_rs1            = 5'b0;
        reg_rs2            = 5'b0;
        reg_rd             = 5'b0;
        reg_write_data     = 32'b0;
        alu_operand1       = 32'b0;
        alu_operand2       = 32'b0;
        memory_address     = 32'b0;
        memory_write_data  = 32'b0;

        case (current_state)
            IDLE: begin
                next_state = FETCH;
            end
            FETCH: begin
                fetch_enable = 1;
                if (fetch_done && instruction_valid)
                    next_state = DECODE;
            end
            DECODE: begin
                decode_enable        = 1;
                instruction_to_decode= instruction;
                if (decode_done)
                    next_state = READ_REGISTER;
            end
            READ_REGISTER: begin
                reg_read_enable = 1;
                reg_rs1 = rs1;
                reg_rs2 = rs2;
                if (reg_read_data_valid)
                    next_state = EXECUTE;
            end
            EXECUTE: begin
                alu_enable = 1;
                alu_operand1 = reg_read_data1;
                alu_operand2 = (instr_type == I_TYPE || instr_type == LOAD_TYPE || instr_type == STORE_TYPE) ? imm : reg_read_data2;
                if (alu_done) begin
                    case (instr_type)
                        R_TYPE, I_TYPE: next_state = WRITE_BACK;
                        LOAD_TYPE, STORE_TYPE: next_state = MEMORY_ACCESS;
                        default: next_state = IDLE;
                    endcase
                end
            end
            MEMORY_ACCESS: begin
                if (instr_type == LOAD_TYPE) begin
                    memory_read_enable = 1;
                    memory_address     = alu_result; // ALU result is memory address
                    if (memory_read_data_valid)
                        next_state = WRITE_BACK;
                end else if (instr_type == STORE_TYPE) begin
                    memory_write_enable = 1;
                    memory_address      = alu_result; // ALU result is memory address
                    memory_write_data   = reg_read_data2; // Data to store
                    if (memory_write_done)
                        next_state = IDLE;
                end
            end
            WRITE_BACK: begin
                reg_write_enable = 1;
                reg_rd           = rd;
                reg_write_data   = (instr_type == LOAD_TYPE) ? memory_read_data : alu_result;
                if (reg_write_done)
                    next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule



    // // Connection to CPU CSR
    // output wire          s_aclk_csr;       // AXI clock signal
    // output wire          s_aresetn_csr;    // AXI reset signal (active-low)

    // // AXI Slave Read Address Channel
    // output wire [4:0]   s_axi_araddr_csr;  // Read address (5 bits)
    // output wire [1:0]   s_axi_arburst_csr; // Burst type
    // output wire [4:0]   s_axi_arid_csr;    // Transaction ID (5 bits)
    // output wire [7:0]   s_axi_arlen_csr;   // Burst length
    // input  reg          s_axi_arready_csr; // Read address ready
    // output wire [2:0]   s_axi_arsize_csr;  // Burst size
    // output wire         s_axi_arvalid_csr; // Read address valid

    // // AXI Slave Write Address Channel
    // output wire [4:0]   s_axi_awaddr_csr;  // Write address (5 bits)
    // output wire [1:0]   s_axi_awburst_csr; // Burst type
    // output wire [4:0]   s_axi_awid_csr;    // Write transaction ID (5 bits)
    // output wire [7:0]   s_axi_awlen_csr;   // Burst length
    // input  reg          s_axi_awready_csr; // Write address ready
    // output wire [2:0]   s_axi_awsize_csr;  // Burst size
    // output wire         s_axi_awvalid_csr; // Write address valid

    // // AXI Slave Write Response Channel
    // input  reg [4:0]    s_axi_bid_csr;     // Write response transaction ID (5 bits)
    // output wire         s_axi_bready_csr;  // Write response ready
    // input  reg [1:0]    s_axi_bresp_csr;   // Write response
    // input  reg          s_axi_bvalid_csr;  // Write response valid

    // // AXI Slave Read Data Channel
    // input  reg [31:0]   s_axi_rdata_csr;   // Read data
    // input  reg [4:0]    s_axi_rid_csr;     // Read transaction ID (5 bits)
    // input  reg          s_axi_rlast_csr;   // Read last
    // output wire         s_axi_rready_csr;  // Read ready
    // input  reg [1:0]    s_axi_rresp_csr;   // Read response
    // input  reg          s_axi_rvalid_csr;  // Read valid

    // // AXI Slave Write Data Channel
    // output wire [31:0]  s_axi_wdata_csr;   // Write data
    // output wire         s_axi_wlast_csr;   // Write last
    // input  reg          s_axi_wready_csr;  // Write data ready
    // output wire [3:0]   s_axi_wstrb_csr;   // Write strobes
    // output wire         s_axi_wvalid_csr;  // Write valid

    // // Optional busy signals
    // input wire          rsta_busy_csr;      // Optional busy signal
    // input wire          rstb_busy_csr;      // Optional busy signal
 

    // //Connection to DCCM Data Memory
    // output wire                       s_aclk_dccm;       // AXI clock signal
    // output wire                       s_aresetn_dccm;    // AXI reset signal (active-low)

    // // AXI Slave Read Address Channel
    // output wire [31:0]                s_axi_araddr_dccm;  // Read address
    // output wire [1:0]                 s_axi_arburst_dccm; // Burst type
    // output wire [3:0]                 s_axi_arid_dccm;    // Transaction ID
    // output wire [7:0]                 s_axi_arlen_dccm;   // Burst length
    // input  wire                       s_axi_arready_dccm; // Read address ready
    // output wire [2:0]                 s_axi_arsize_dccm;  // Burst size
    // output wire                       s_axi_arvalid_dccm; // Read address valid

    // // AXI Slave Write Address Channel
    // output wire [31:0]                s_axi_awaddr_dccm;  // Write address
    // output wire [1:0]                 s_axi_awburst_dccm; // Burst type
    // output wire [3:0]                 s_axi_awid_dccm;    // Write transaction ID
    // output wire [7:0]                 s_axi_awlen_dccm;   // Burst length
    // input  wire                       s_axi_awready_dccm; // Write address ready
    // output wire [2:0]                 s_axi_awsize_dccm;  // Burst size
    // output wire                       s_axi_awvalid_dccm; // Write address valid

    // // AXI Slave Write Response Channel
    // input  wire [3:0]                 s_axi_bid_dccm;     // Write response transaction ID
    // output wire                       s_axi_bready_dccm;  // Write response ready
    // input  wire [1:0]                 s_axi_bresp_dccm;   // Write response
    // input  wire                       s_axi_bvalid_dccm;  // Write response valid

    // // AXI Slave Read Data Channel
    // input  wire [31:0]                s_axi_rdata_dccm;   // Read data
    // input  wire [3:0]                 s_axi_rid_dccm;     // Read transaction ID
    // input  wire                       s_axi_rlast_dccm;   // Read last
    // output wire                       s_axi_rready_dccm;  // Read ready
    // input  wire [1:0]                 s_axi_rresp_dccm;   // Read response
    // input  wire                       s_axi_rvalid_dccm;  // Read valid

    // // AXI Slave Write Data Channel
    // output wire [31:0]                s_axi_wdata_dccm;   // Write data
    // output wire                       s_axi_wlast_dccm;   // Write last
    // input  wire                       s_axi_wready_dccm;  // Write data ready
    // output wire [3:0]                 s_axi_wstrb_dccm;   // Write strobes
    // output wire                       s_axi_wvalid_dccm;  // Write valid

    // // Optional busy signals (rsta_busy, rstb_busy)
    // input wire                       rsta_busy_dccm;      // Optional busy signal
    // input wire                       rstb_busy_dccm;      // Optional busy signal