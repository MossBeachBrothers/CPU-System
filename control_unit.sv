module control_unit (
    input wire clk,
    input wire reset_n, // Added a reset input for better FSM initialization


    // Connection to IFU
    output wire fetch_en, // Tell IFU to search
    output wire fetch_address, // Where IFU should search

    input wire fetch_done, // IFU tell Control that its done
    input logic[31:0] instruction,  // instruction from IFU

    // Connection to IDU
    output logic decode_en, //Tell Decoder to Decode
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