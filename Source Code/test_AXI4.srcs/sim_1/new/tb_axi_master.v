`timescale 1ns / 1ps

module tb_AXI_MASTER();

    // Clock & Reset
    reg aclk;
    reg aresetn;

    // Input signals
    reg [15:0] input_wr_addr;
    reg [7:0]  input_wr_len;
    reg [2:0]  input_wr_size;
    reg [1:0]  input_wr_burst;
    reg        input_wr_valid;
    reg [31:0] input_wr_data;

    wire [15:0] awaddr;
    wire [7:0]  awlen;
    wire [2:0]  awsize;
    wire [1:0]  awburst;
    wire        awvalid;
    reg         awready;
    
    // Slave response signals
    wire [31:0] wdata;
    wire        wlast;
    wire        wvalid;
    reg         wready;
    
    reg [1:0] bresp;
    reg       bvalid;
    wire      bready;
    
    reg [15:0] input_re_addr;
    reg [7:0]  input_re_len;
    reg [2:0]  input_re_size;
    reg [1:0]  input_re_burst;
    reg        input_re_arvalid;
    
    wire [15:0] araddr;
    wire [7:0]  arlen;
    wire [2:0]  arsize;
    wire [1:0]  arburst;
    wire        arvalid;
    reg         arready;
    
    reg [31:0]  rdata;
    reg [1:0]   rresp;
    reg         rlast;
    reg         rvalid;
    wire        rready;




    // Instantiate DUT
    AXI_MASTER dut (
        .aclk(aclk),
        .aresetn(aresetn),

        .input_wr_addr(input_wr_addr),
        .input_wr_len(input_wr_len),
        .input_wr_size(input_wr_size),
        .input_wr_burst(input_wr_burst),
        .input_wr_valid(input_wr_valid),
        .input_wr_data(input_wr_data),

        .awready(awready),

        .wdata(wdata),
        .wready(wready),
        .wvalid(wvalid),
        .wlast(wlast),
        
        .bready(bready),
        .bvalid(bvalid),
        .bresp(bresp),

        .awaddr(awaddr),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awvalid(awvalid),
        
        .input_re_addr(input_re_addr),
        .input_re_len(input_re_len),
        .input_re_size(input_re_size),
        .input_re_burst(input_re_burst),
        .input_re_arvalid(input_re_arvalid),
        
        .arready(arready),
        .araddr(araddr),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arvalid(arvalid),





        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready)
    );

    // Clock generation
    always #5 aclk = ~aclk;

    initial begin
        aclk = 0;
        aresetn = 0;
        awready = 0;
        wready  = 0;
        bvalid  = 0;
        arready = 0;
        rvalid  = 0;
        rlast   = 0;

        input_wr_valid = 0;
        input_re_arvalid = 0;

        #20;
        aresetn = 1;
        // === WRITE TEST ===
        input_wr_addr = 16'h0004;
        input_wr_len  = 8'd3; // 4 beats
        input_wr_size = 3'b010; // 4 bytes
        input_wr_burst = 2'b01; // INCR
        input_wr_valid = 1;
        input_wr_data  = 32'hDEADBEEF;
        awready = 1;
        wready  = 1;
        bvalid = 1;
        bresp  = 2'b00;

    end

endmodule
