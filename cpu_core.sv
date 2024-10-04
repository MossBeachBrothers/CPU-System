`timescale 1ns / 1ps

module cpu_core (
    input wire clk,
    input wire reset_n,
    input wire enable

    // AXI input signals
    // Add AXI signals here
);

wire ctrl_fetch_enable;
wire ctrl_decode_enable;
wire ctrl_reg_read_enable;
wire ctrl_reg_write_enable;
wire ctrl_alu_enable;
wire ctrl_mem_read_enable;
wire ctrl_mem_write_enable;


wire stat_fetch_done; 
wire stat_decode_done;
wire stat_alu_done;
wire stat_mem_write_done;

// IFU output
wire instruction_fetched;
wire instruction_valid;

// IDU input and output

logic [31:0] instruction_to_decode;
logic [6:0] opcode;
logic [4:0] rd;
logic [2:0] funct3;
logic [4:0] rs1;
logic [4:0] rs2;
logic [6:0] funct7;
logic [31:0] imm;
logic [2:0] instr_type;

// Register File Input   
logic [4:0] reg_read_address1;              
logic [4:0] reg_read_address2;              
logic [4:0] reg_rd;               
logic [31:0] reg_write_data;       
logic [31:0] reg_read_data1;       
logic [31:0] reg_read_data2;       
logic reg_read_data_valid;  
logic reg_write_done;       


logic [31:0] alu_operand1;
logic [31:0] alu_operand2;
logic [31:0] alu_result;



//MAU

logic [31:0] memory_access_address;
logic [31:0] memory_write_data;
logic [31:0] memory_read_data;
logic memory_read_data_valid;




//ICCM READ SIGNALS

//read address
logic [31:0]                iccm_axi_araddr;
logic [1:0]                 iccm_axi_arburst;
logic [3:0]                 iccm_axi_arid;
logic [7:0]                 iccm_axi_arlen;
logic                       iccm_axi_arready;
logic [2:0]                 iccm_axi_arsize;
logic                       iccm_axi_arvalid;
//read data 
logic [31:0]                iccm_axi_rdata;
logic [3:0]                 iccm_axi_rid;
logic                       iccm_axi_rlast;
logic                       iccm_axi_rready;
logic [1:0]                 iccm_axi_rresp;
logic                       iccm_axi_rvalid;
//write address
logic [31:0]                iccm_axi_awaddr;
logic [1:0]                 iccm_axi_awburst;
logic [3:0]                 iccm_axi_awid;
logic [7:0]                 iccm_axi_awlen;
logic                       iccm_axi_awready;
logic [2:0]                 iccm_axi_awsize;
logic                       iccm_axi_awvalid;
//write response
logic [3:0]                 iccm_axi_bid;
logic                       iccm_axi_bready;
logic [1:0]                 iccm_axi_bresp;
logic                       iccm_axi_bvalid;
//write data
logic [31:0]                iccm_axi_wdata;
logic                       iccm_axi_wlast;
logic                       iccm_axi_wready;
logic [3:0]                 iccm_axi_wstrb;
logic                       iccm_axi_wvalid;

logic                       iccm_rsta_busy;
logic                       iccm_rstb_busy;




//DCCM 
// read address 
logic [31:0]                dccm_axi_araddr;
logic [1:0]                 dccm_axi_arburst;
logic [3:0]                 dccm_axi_arid;
logic [7:0]                 dccm_axi_arlen;
logic                       dccm_axi_arready;
logic [2:0]                 dccm_axi_arsize;
logic                       dccm_axi_arvalid;
// read data 
logic [31:0]                dccm_axi_rdata;
logic [3:0]                 dccm_axi_rid;
logic                       dccm_axi_rlast;
logic                       dccm_axi_rready;
logic [1:0]                 dccm_axi_rresp;
logic                       dccm_axi_rvalid;
//write address 
logic [31:0]                dccm_axi_awaddr;
logic [1:0]                 dccm_axi_awburst;
logic [3:0]                 dccm_axi_awid;
logic [7:0]                 dccm_axi_awlen;
logic                       dccm_axi_awready;
logic [2:0]                 dccm_axi_awsize;
logic                       dccm_axi_awvalid;
//write response 
logic [3:0]                 dccm_axi_bid;
logic                       dccm_axi_bready;
logic [1:0]                 dccm_axi_bresp;
logic                       dccm_axi_bvalid;
//write data 
logic [31:0]                dccm_axi_wdata;
logic                       dccm_axi_wlast;
logic                       dccm_axi_wready;
logic [3:0]                 dccm_axi_wstrb;
logic                       dccm_axi_wvalid;

logic                       dccm_rsta_busy;
logic                       dccm_rstb_busy;


control_unit cu_inst (
    .clk(clk),
    .reset_n(reset_n),

    .fetch_enable(ctrl_fetch_enable), 
    .fetch_done(stat_fetch_done),
    .instruction(instruction_fetched),

    .decode_enable(ctrl_decode_enable),
    .instruction_to_decode(instruction_to_decode),
    .decode_done(stat_decode_done),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .imm(imm),
    .instr_type(instr_type),

    //Need to fix Register FIle Bug
    .reg_read_enable(ctrl_reg_read_enable),
    .reg_write_enable(ctrl_reg_write_enable),
    .reg_rs1(reg_read_address1),
    .reg_rs2(reg_read_address2),
    .reg_rd(reg_rd),


    .alu_enable(ctrl_alu_enable),
    .alu_operand1(alu_operand1),
    .alu_operand2(alu_operand2),
    .alu_done(stat_alu_done),
    .alu_result(alu_result),

    .memory_read_enable(ctrl_mem_read_enable),
    .memory_write_enable(ctrl_mem_write_enable),
    .memory_address(memory_access_address),
    .memory_write_data(memory_write_data),
    .memory_read_data(memory_read_data),
    .memory_read_data_valid(memory_read_data_valid),
    .memory_write_done(memory_write_done)

);

instruction_fetch_unit ifu_inst (
    .clk(clk),
    .resetn(reset_n),
    .fetch_enable(ctrl_fetch_enable),
    .fetch_addr(), //add fetch address
    .instruction(instruction_fetched),
    .instr_valid(stat_fetch_done),

    //add AXI signals to iccm for read
    .s_axi_raddr(),
    .s_axi_arburst(),
    .s_axi_arid(),
    .s_axi_arlen(),
    .s_axi_arvalid(),
    .s_axi_arready(),
    .s_axi_rdata(),
    .s_axi_rvalid(),
    .s_axi_rready()
);

instruction_decode_unit idu_inst (
    .instruction(instruction_to_decode),
    .enable(ctrl_decode_enable),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .imm(imm),
    .instr_type(instr_type)
);

iccm_wrapper iccm_inst (
    .s_aclk(clk),
    .s_aresetn(reset_n),
    // AXI Slave Read Address Channel
    .s_axi_araddr(iccm_axi_araddr),
    .s_axi_arburst(iccm_axi_arburst),
    .s_axi_arid(iccm_axi_arid),
    .s_axi_arlen(iccm_axi_arlen),
    .s_axi_arready(iccm_axi_arready),
    .s_axi_arsize(iccm_axi_arsize),
    .s_axi_arvalid(iccm_axi_arvalid),

    // AXI Slave Write Address Channel
    .s_axi_awaddr(iccm_axi_awaddr),
    .s_axi_awburst(iccm_axi_awburst),
    .s_axi_awid(iccm_axi_awid),
    .s_axi_awlen(iccm_axi_awlen),
    .s_axi_awready(iccm_axi_awready),
    .s_axi_awsize(iccm_axi_awsize),
    .s_axi_awvalid(iccm_axi_awvalid),

    // AXI Slave Write Response Channel
    .s_axi_bid(iccm_axi_bid),
    .s_axi_bready(iccm_axi_bready),
    .s_axi_bresp(iccm_axi_bresp),
    .s_axi_bvalid(iccm_axi_bvalid),

    // AXI Slave Read Data Channel
    .s_axi_rdata(iccm_axi_rdata),
    .s_axi_rid(iccm_axi_rid),
    .s_axi_rlast(iccm_axi_rlast),
    .s_axi_rready(iccm_axi_rready),
    .s_axi_rresp(iccm_axi_rresp),
    .s_axi_rvalid(iccm_axi_rvalid),

    // AXI Slave Write Data Channel
    .s_axi_wdata(iccm_axi_wdata),
    .s_axi_wlast(iccm_axi_wlast),
    .s_axi_wready(iccm_axi_wready),
    .s_axi_wstrb(iccm_axi_wstrb),
    .s_axi_wvalid(iccm_axi_wvalid),

    // Optional busy signals
    .rsta_busy(iccm_rsta_busy),
    .rstb_busy(iccm_rstb_busy)
); 

dccm_wrapper dccm_inst (
    .s_aclk(clk),
    .s_aresetn(reset_n),
    
    // Address Channel
    .s_axi_araddr(dccm_axi_araddr),
    .s_axi_arburst(dccm_axi_arburst),
    .s_axi_arid(dccm_axi_arid),
    .s_axi_arlen(dccm_axi_arlen),
    .s_axi_arready(dccm_axi_arready),
    .s_axi_arsize(dccm_axi_arsize),
    .s_axi_arvalid(dccm_axi_arvalid),

    // Write Address Channel
    .s_axi_awaddr(dccm_axi_awaddr),
    .s_axi_awburst(dccm_axi_awburst),
    .s_axi_awid(dccm_axi_awid),
    .s_axi_awlen(dccm_axi_awlen),
    .s_axi_awready(dccm_axi_awready),
    .s_axi_awsize(dccm_axi_awsize),
    .s_axi_awvalid(dccm_axi_awvalid),

    // Write Response Channel
    .s_axi_bid(dccm_axi_bid),
    .s_axi_bready(dccm_axi_bready),
    .s_axi_bresp(dccm_axi_bresp),
    .s_axi_bvalid(dccm_axi_bvalid),

    // Read Data Channel
    .s_axi_rdata(dccm_axi_rdata),
    .s_axi_rid(dccm_axi_rid),
    .s_axi_rlast(dccm_axi_rlast),
    .s_axi_rready(dccm_axi_rready),
    .s_axi_rresp(dccm_axi_rresp),
    .s_axi_rvalid(dccm_axi_rvalid),

    // Write Data Channel
    .s_axi_wdata(dccm_axi_wdata),
    .s_axi_wlast(dccm_axi_wlast),
    .s_axi_wready(dccm_axi_wready),
    .s_axi_wstrb(dccm_axi_wstrb),
    .s_axi_wvalid(dccm_axi_wvalid),
    
    // Additional Signals
    .rsta_busy(dccm_rsta_busy),
    .rstb_busy(dccm_rstb_busy)
);

mau mau_inst (
    .clk(clk),
    .resetn(reset_n),
    .access_enable(ctrl_mem_read_enable | ctrl_mem_write_enable),
    .read_enable(ctrl_mem_read_enable),
    .write_enable(ctrl_mem_write_enable),
    .access_addr(memory_access_address),
    .write_data(memory_write_data),
    .read_data(memory_read_data),
    .data_valid(memory_read_data_valid),
    .write_done(stat_mem_write_done),

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
    .s_axi_wready(dccm_axi_wready),
    .s_axi_rdata(dccm_axi_rdata),
    .s_axi_rvalid(dccm_axi_rvalid),
    .s_axi_bvalid(dccm_axi_bvalid),
    .s_axi_rready(dccm_axi_rready),
    .s_axi_bready(dccm_axi_bready)
);







endmodule