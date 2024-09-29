`timescale 1ns / 1ps

module cpu_core (
    input wire clk,
    input wire resetn
);

    // Program Counter Signals
    wire [31:0] pc_out;
    wire [31:0] jump_address;
    wire branch_taken;

    // Instruction Fetch Unit Signals
    wire fetch_enable;
    wire fetch_done;
    wire [31:0] instruction;
    wire [31:0] fetch_addr;

    // Instruction Decode Unit Signals
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;
    wire [31:0] imm;
    wire [2:0] instr_type;
    wire decode_enable;
    wire decode_done;
    wire [31:0] instruction_to_decode;

    // Control Unit Signals
    wire reg_read_enable;
    wire reg_write_enable;
    wire [4:0] reg_rs1;
    wire [4:0] reg_rs2;
    wire [4:0] reg_rd;
    wire [31:0] reg_write_data;
    wire [31:0] reg_read_data1;
    wire [31:0] reg_read_data2;
    wire reg_read_data_valid;
    wire reg_write_done;
    wire alu_enable;
    wire [31:0] alu_operand1;
    wire [31:0] alu_operand2;
    wire alu_done;
    wire [31:0] alu_result;
    wire memory_read_enable;
    wire memory_write_enable;
    wire [31:0] memory_address;
    wire [31:0] memory_write_data;
    wire [31:0] memory_read_data;
    wire memory_read_data_valid;
    wire memory_write_done;

    // ALU Signals
    // (Already covered above)

    // Register File Signals
    wire [31:0] rdata1;
    wire [31:0] rdata2;

    // Memory Access Unit (MAU) Signals
    wire access_enable;
    wire read_enable;
    wire write_enable;
    wire [31:0] access_addr;
    wire [31:0] write_data;
    wire [31:0] read_data;
    wire data_valid;
    wire write_done_mau;

    // ICCM AXI Interface Signals
    wire [31:0] iccm_axi_araddr;
    wire [1:0]  iccm_axi_arburst;
    wire [3:0]  iccm_axi_arid;
    wire [7:0]  iccm_axi_arlen;
    wire        iccm_axi_arvalid;
    wire        iccm_axi_arready;
    wire [31:0] iccm_axi_rdata;
    wire [3:0]  iccm_axi_rid;
    wire        iccm_axi_rlast;
    wire [1:0]  iccm_axi_rresp;
    wire        iccm_axi_rvalid;
    wire        iccm_axi_rready;

    // DCCM AXI Interface Signals
    wire [31:0] dccm_axi_araddr;
    wire [1:0]  dccm_axi_arburst;
    wire [3:0]  dccm_axi_arid;
    wire [7:0]  dccm_axi_arlen;
    wire        dccm_axi_arvalid;
    wire        dccm_axi_arready;
    wire [31:0] dccm_axi_rdata;
    wire [3:0]  dccm_axi_rid;
    wire        dccm_axi_rlast;
    wire [1:0]  dccm_axi_rresp;
    wire        dccm_axi_rvalid;
    wire        dccm_axi_rready;
    wire [31:0] dccm_axi_awaddr;
    wire [1:0]  dccm_axi_awburst;
    wire [3:0]  dccm_axi_awid;
    wire [7:0]  dccm_axi_awlen;
    wire        dccm_axi_awvalid;
    wire        dccm_axi_awready;
    wire [31:0] dccm_axi_wdata;
    wire [3:0]  dccm_axi_wstrb;
    wire        dccm_axi_wlast;
    wire        dccm_axi_wvalid;
    wire        dccm_axi_wready;
    wire [3:0]  dccm_axi_bid;
    wire [1:0]  dccm_axi_bresp;
    wire        dccm_axi_bvalid;
    wire        dccm_axi_bready;

    // Instantiate Program Counter
    program_counter pc_inst (
        .clk(clk),
        .rst_n(resetn),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .pc_out(pc_out)
    );

    // Instantiate ICCM Wrapper
    iccm_wrapper iccm_inst (
        .s_aclk(clk),
        .s_aresetn(resetn),
        .s_axi_araddr(iccm_axi_araddr),
        .s_axi_arburst(iccm_axi_arburst),
        .s_axi_arid(iccm_axi_arid),
        .s_axi_arlen(iccm_axi_arlen),
        .s_axi_arready(iccm_axi_arready),
        .s_axi_arsize(3'b010),
        .s_axi_arvalid(iccm_axi_arvalid),
        .s_axi_awaddr(32'd0),
        .s_axi_awburst(2'd0),
        .s_axi_awid(4'd0),
        .s_axi_awlen(8'd0),
        .s_axi_awready(),
        .s_axi_awsize(3'd0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(),
        .s_axi_bready(1'b0),
        .s_axi_bresp(),
        .s_axi_bvalid(),
        .s_axi_rdata(iccm_axi_rdata),
        .s_axi_rid(iccm_axi_rid),
        .s_axi_rlast(iccm_axi_rlast),
        .s_axi_rready(iccm_axi_rready),
        .s_axi_rresp(iccm_axi_rresp),
        .s_axi_rvalid(iccm_axi_rvalid),
        .s_axi_wdata(32'd0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(),
        .s_axi_wstrb(4'd0),
        .s_axi_wvalid(1'b0),
        .rsta_busy(),
        .rstb_busy()
    );

    // Instantiate DCCM Wrapper
    dccm_wrapper dccm_inst (
        .s_aclk(clk),
        .s_aresetn(resetn),
        .s_axi_araddr(dccm_axi_araddr),
        .s_axi_arburst(dccm_axi_arburst),
        .s_axi_arid(dccm_axi_arid),
        .s_axi_arlen(dccm_axi_arlen),
        .s_axi_arready(dccm_axi_arready),
        .s_axi_arsize(3'b010),
        .s_axi_arvalid(dccm_axi_arvalid),
        .s_axi_awaddr(dccm_axi_awaddr),
        .s_axi_awburst(dccm_axi_awburst),
        .s_axi_awid(dccm_axi_awid),
        .s_axi_awlen(dccm_axi_awlen),
        .s_axi_awready(dccm_axi_awready),
        .s_axi_awsize(3'b010),
        .s_axi_awvalid(dccm_axi_awvalid),
        .s_axi_bid(dccm_axi_bid),
        .s_axi_bready(dccm_axi_bready),
        .s_axi_bresp(dccm_axi_bresp),
        .s_axi_bvalid(dccm_axi_bvalid),
        .s_axi_rdata(dccm_axi_rdata),
        .s_axi_rid(dccm_axi_rid),
        .s_axi_rlast(dccm_axi_rlast),
        .s_axi_rready(dccm_axi_rready),
        .s_axi_rresp(dccm_axi_rresp),
        .s_axi_rvalid(dccm_axi_rvalid),
        .s_axi_wdata(dccm_axi_wdata),
        .s_axi_wlast(dccm_axi_wlast),
        .s_axi_wready(dccm_axi_wready),
        .s_axi_wstrb(dccm_axi_wstrb),
        .s_axi_wvalid(dccm_axi_wvalid),
        .rsta_busy(),
        .rstb_busy()
    );

    // Instantiate Instruction Fetch Unit
    instruction_fetch_unit ifu_inst (
        .clk(clk),
        .resetn(resetn),
        .fetch_enable(fetch_enable),
        .fetch_addr(pc_out),
        .instruction(instruction),
        .instr_valid(fetch_done),
        .s_axi_araddr(iccm_axi_araddr),
        .s_axi_arburst(iccm_axi_arburst),
        .s_axi_arid(iccm_axi_arid),
        .s_axi_arlen(iccm_axi_arlen),
        .s_axi_arvalid(iccm_axi_arvalid),
        .s_axi_arready(iccm_axi_arready),
        .s_axi_rdata(iccm_axi_rdata),
        .s_axi_rvalid(iccm_axi_rvalid),
        .s_axi_rready(iccm_axi_rready)
    );

    // Instantiate Instruction Decode Unit
    instruction_decode_unit idu_inst (
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

    // Instantiate Control Unit
    control_unit cu_inst (
        .clk(clk),
        .reset_n(resetn),
        .fetch_enable(fetch_enable),
        .fetch_done(fetch_done),
        .instruction(instruction),
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
        .alu_enable(alu_enable),
        .alu_operand1(alu_operand1),
        .alu_operand2(alu_operand2),
        .alu_done(alu_done),
        .alu_result(alu_result),
        .memory_read_enable(memory_read_enable),
        .memory_write_enable(memory_write_enable),
        .memory_address(memory_address),
        .memory_write_data(memory_write_data),
        .memory_read_data(memory_read_data),
        .memory_read_data_valid(memory_read_data_valid),
        .memory_write_done(memory_write_done)
    );

    // Instantiate Register File
    register_file reg_file_inst (
        .clk(clk),
        .rst_n(resetn),
        .we(reg_write_enable),
        .re(1'b1),
        .addr(reg_rs1),
        .wdata(reg_write_data),
        .rdata(reg_read_data1),
        .busy(),
        .read_valid(reg_read_data_valid),
        .write_resp_valid(reg_write_done),
        .write_resp()
    );

    // Instantiate ALU
    alu alu_inst (
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .funct7(funct7),
        .imm(imm),
        .instr_type(instr_type),
        .pc(pc_out),
        .rs1_data(reg_read_data1),
        .rs2_data(reg_read_data1), // Assuming rs2_data is same as rs1_data for simplicity
        .alu_result(alu_result),
        .branch_taken(branch_taken)
    );

    // Instantiate Memory Access Unit (MAU)
    mau mau_inst (
        .clk(clk),
        .resetn(resetn),
        .access_enable(memory_read_enable | memory_write_enable),
        .read_enable(memory_read_enable),
        .write_enable(memory_write_enable),
        .access_addr(memory_address),
        .write_data(memory_write_data),
        .read_data(memory_read_data),
        .data_valid(memory_read_data_valid),
        .write_done(write_done_mau),
        .s_axi_araddr(dccm_axi_araddr),
        .s_axi_awaddr(dccm_axi_awaddr),
        .s_axi_arburst(dccm_axi_arburst),
        .s_axi_awburst(dccm_axi_awburst),
        .s_axi_arid(dccm_axi_arid),
        .s_axi_awid(dccm_axi_awid),
        .s_axi_arlen(dccm_axi_arlen),
        .s_axi_awlen(dccm_axi_awlen),
        .s_axi_arvalid(dccm_axi_arvalid),
        .s_axi_awvalid(dccm_axi_awvalid),
        .s_axi_wdata(dccm_axi_wdata),
        .s_axi_wvalid(dccm_axi_wvalid),
        .s_axi_arready(dccm_axi_arready),
        .s_axi_awready(dccm_axi_awready),
        .s_axi_wready(dccm_axi_wready),
        .s_axi_rdata(dccm_axi_rdata),
        .s_axi_rvalid(dccm_axi_rvalid),
        .s_axi_bvalid(dccm_axi_bvalid),
        .s_axi_rready(dccm_axi_rready),
        .s_axi_bready(dccm_axi_bready)
    );

endmodule
