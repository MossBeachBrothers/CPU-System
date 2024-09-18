module cpu_csr (
    input  wire          s_aclk,
    input  wire          s_aresetn,
    
    input  wire [4:0]    s_axi_araddr,
    input  wire [1:0]    s_axi_arburst,
    input  wire [4:0]    s_axi_arid,
    input  wire [7:0]    s_axi_arlen,
    output reg           s_axi_arready,
    input  wire [2:0]    s_axi_arsize,
    input  wire          s_axi_arvalid,
    
    input  wire [4:0]    s_axi_awaddr,
    input  wire [1:0]    s_axi_awburst,
    input  wire [4:0]    s_axi_awid,
    input  wire [7:0]    s_axi_awlen,
    output reg           s_axi_awready,
    input  wire [2:0]    s_axi_awsize,
    input  wire          s_axi_awvalid,
    
    output reg [4:0]     s_axi_bid,
    input  wire          s_axi_bready,
    output reg [1:0]     s_axi_bresp,
    output reg           s_axi_bvalid,
    
    output reg [31:0]    s_axi_rdata,
    output reg [4:0]     s_axi_rid,
    output reg           s_axi_rlast,
    input  wire          s_axi_rready,
    output reg [1:0]     s_axi_rresp,
    output reg           s_axi_rvalid,
    
    input  wire [31:0]   s_axi_wdata,
    input  wire          s_axi_wlast,
    output reg           s_axi_wready,
    input  wire [3:0]    s_axi_wstrb,
    input  wire          s_axi_wvalid,
    
    output wire          rsta_busy,
    output wire          rstb_busy
);
    reg [31:0] regs [31:0];
    
    assign rsta_busy = 1'b0;
    assign rstb_busy = 1'b0;
    
    reg aw_valid;
    reg [4:0] awaddr_reg;
    reg [4:0] awid_reg;
    
    reg w_valid;
    reg [31:0] wdata_reg;
    reg [3:0] wstrb_reg;
    
    reg write_resp_pending;
    
    reg ar_valid;
    reg [4:0] araddr_reg;
    reg [4:0] arid_reg;
    
    reg read_data_pending;
    
    integer i;
    
    initial begin
        s_axi_awready = 1'b0;
        s_axi_wready = 1'b0;
        s_axi_bvalid = 1'b0;
        s_axi_bid = 5'd0;
        s_axi_bresp = 2'b00;
        
        s_axi_arready = 1'b0;
        s_axi_rvalid = 1'b0;
        s_axi_rdata = 32'd0;
        s_axi_rid = 5'd0;
        s_axi_rlast = 1'b0;
        s_axi_rresp = 2'b00;
        
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'd0;
        end
    end
    
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_awready <= 1'b0;
            aw_valid <= 1'b0;
            awaddr_reg <= 5'd0;
            awid_reg <= 5'd0;
        end else begin
            if (!s_axi_awready && s_axi_awvalid) begin
                s_axi_awready <= 1'b1;
                awaddr_reg <= s_axi_awaddr;
                awid_reg <= s_axi_awid;
                aw_valid <= 1'b1;
                $display("Write Address accepted: addr=%0d, id=%0d", awaddr_reg, awid_reg);
            end else begin
                s_axi_awready <= 1'b0;
            end
        end
    end
    
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_wready <= 1'b0;
            w_valid <= 1'b0;
            wdata_reg <= 32'd0;
            wstrb_reg <= 4'd0;
        end else begin
            if (!s_axi_wready && s_axi_wvalid) begin
                s_axi_wready <= 1'b1;
                wdata_reg <= s_axi_wdata;
                wstrb_reg <= s_axi_wstrb;
                w_valid <= 1'b1;
                $display("Write Data accepted: data=0x%0h", wdata_reg);
            end else begin
                s_axi_wready <= 1'b0;
            end
        end
    end
    
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            write_resp_pending <= 1'b0;
            s_axi_bvalid <= 1'b0;
        end else begin
            if (aw_valid && w_valid && !write_resp_pending) begin
                if (awaddr_reg < 32) begin
                    integer i_byte;
                    for (i_byte = 0; i_byte < 4; i_byte = i_byte + 1) begin
                        if (wstrb_reg[i_byte]) begin
                            regs[awaddr_reg][8*i_byte + 7 -: 8] <= wdata_reg[8*i_byte + 7 -: 8];
                            $display("Writing 0x%0h to regs[%0d]", wdata_reg[8*i_byte + 7 -: 8], awaddr_reg);
                        end
                    end
                end
                s_axi_bvalid <= 1'b1;
                s_axi_bid <= awid_reg;
                s_axi_bresp <= 2'b00; 
                write_resp_pending <= 1'b1;
                aw_valid <= 1'b0; 
                w_valid <= 1'b0; 
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
                write_resp_pending <= 1'b0;
            end
        end
    end
    
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_arready <= 1'b0;
            ar_valid <= 1'b0;
            araddr_reg <= 5'd0;
            arid_reg <= 5'd0;
        end else begin
            if (!s_axi_arready && s_axi_arvalid) begin
                s_axi_arready <= 1'b1;
                araddr_reg <= s_axi_araddr;
                arid_reg <= s_axi_arid;
                ar_valid <= 1'b1;
                $display("Read Address accepted: addr=%0d, id=%0d", araddr_reg, arid_reg);
            end else begin
                s_axi_arready <= 1'b0;
            end
        end
    end
    
    always @(posedge s_aclk) begin
        if (!s_aresetn) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata <= 32'd0;
            s_axi_rid <= 5'd0;
            s_axi_rlast <= 1'b0;
            s_axi_rresp <= 2'b00;
            read_data_pending <= 1'b0;
        end else begin
            if (ar_valid && !read_data_pending) begin
                if (araddr_reg < 32) begin
                    s_axi_rdata <= regs[araddr_reg];
                    s_axi_rresp <= 2'b00; 
                    $display("Reading 0x%0h from regs[%0d]", s_axi_rdata, araddr_reg);
                end else begin
                    s_axi_rdata <= 32'd0;
                    s_axi_rresp <= 2'b10; 
                end
                s_axi_rid <= arid_reg;
                s_axi_rvalid <= 1'b1;
                s_axi_rlast <= 1'b1;
                read_data_pending <= 1'b1;
                ar_valid <= 1'b0; 
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
                read_data_pending <= 1'b0;
            end
        end
    end
endmodule
