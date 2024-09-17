module instruction_fetch_unit (
    input  wire        s_aclk,
    input  wire        s_aresetn,
    input  wire [31:0] address,
    input  wire        fetch,
    output reg  [31:0] instruction,

    // AXI Master Interface Ports
    // AXI4 Master Read Address Channel Signals
    output reg [31:0] m_axi_araddr,
    output reg [1:0]  m_axi_arburst,
    output reg [3:0]  m_axi_arid,
    output reg [7:0]  m_axi_arlen,
    input  wire       m_axi_arready,
    output reg [2:0]  m_axi_arsize,
    output reg        m_axi_arvalid,

    // AXI4 Master Read Data Channel Signals
    input  wire [31:0] m_axi_rdata,
    input  wire [3:0]  m_axi_rid,
    input  wire        m_axi_rlast,
    output reg         m_axi_rready,
    input  wire [1:0]  m_axi_rresp,
    input  wire        m_axi_rvalid
);

    // State Machine Definition
    typedef enum logic [1:0] {
        IDLE,
        READ_ADDR,
        READ_DATA
    } state_t;

    state_t state;

    // State Machine for AXI Read Transactions
    always_ff @(posedge s_aclk) begin
        if (~s_aresetn) begin
            state           <= IDLE;
            m_axi_araddr    <= 32'd0;
            m_axi_arburst   <= 2'd0;
            m_axi_arid      <= 4'd0;
            m_axi_arlen     <= 8'd0;
            m_axi_arsize    <= 3'd0;
            m_axi_arvalid   <= 1'b0;
            m_axi_rready    <= 1'b0;
            instruction     <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (fetch) begin
                        // Issue Read Address
                        m_axi_araddr  <= address;
                        m_axi_arburst <= 2'b01;  // INCR burst
                        m_axi_arid    <= 4'd0;   // Transaction ID
                        m_axi_arlen   <= 8'd0;   // Single beat
                        m_axi_arsize  <= 3'd2;   // 4 bytes per beat
                        m_axi_arvalid <= 1'b1;
                        m_axi_rready  <= 1'b0;
                        state         <= READ_ADDR;
                    end
                end
                READ_ADDR: begin
                    if (m_axi_arvalid && m_axi_arready) begin
                        // Read Address Handshake Complete
                        m_axi_arvalid <= 1'b0;
                        m_axi_rready  <= 1'b1;
                        state         <= READ_DATA;
                    end
                end
                READ_DATA: begin
                    if (m_axi_rvalid && m_axi_rready) begin
                        // Read Data Available
                        instruction <= m_axi_rdata;
                        if (m_axi_rlast) begin
                            m_axi_rready <= 1'b0;
                            state        <= IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule
