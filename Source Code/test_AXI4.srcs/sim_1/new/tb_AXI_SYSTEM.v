`timescale 1ns / 1ps

module tb_axi_system;

    // Clock and Reset
    reg aclk;
    reg aresetn;

    // Output wire from master
    wire [15:0] awaddr;
    wire [7:0]  awlen;
    wire [2:0]  awsize;
    wire [1:0]  awburst;
    wire        awvalid;
    wire        awready;

    wire [31:0] wdata;
    wire        wlast;
    wire        wvalid;
    wire        wready;

    wire [1:0]  bresp;
    wire        bvalid;
    wire        bready;
    
    wire [15:0] araddr;
    wire [7:0]  arlen;
    wire [2:0]  arsize;
    wire [1:0]  arburst;
    wire        arvalid;
    wire        arready;

    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    wire        rlast;
    wire        rready;
    
    reg         input_wr_valid;
    reg [15:0]  input_wr_addr;
    reg [7:0]   input_wr_len;
    reg [2:0]   input_wr_size;
    reg [1:0]   input_wr_burst;
    reg [31:0]  input_wr_data;
    
    reg         input_re_arvalid;
    reg [15:0]  input_re_addr;
    reg [7:0]   input_re_len;
    reg [2:0]   input_re_size;
    reg [1:0]   input_re_burst;
    reg [31:0]  input_re_data;

    // Instantiate DUTs
    AXI_MASTER uut_master (
        .aclk(aclk),
        .aresetn(aresetn),
        .input_wr_addr(input_wr_addr),
        .input_wr_len(input_wr_len),
        .input_wr_size(input_wr_size),
        .input_wr_burst(input_wr_burst),
        .input_wr_valid(input_wr_valid),
        .input_wr_data(input_wr_data),
        .input_re_addr(input_re_addr),
        .input_re_len(input_re_len),
        .input_re_size(input_re_size),
        .input_re_burst(input_re_burst),
        .input_re_arvalid(input_re_arvalid),

        .awready(awready),
        .wready(wready),
        .bvalid(bvalid),
        .bresp(bresp),

        .awaddr(awaddr),
        .awlen(awlen),
        .awsize(awsize),
        .awburst(awburst),
        .awvalid(awvalid),

        .arready(arready),
        .araddr(araddr),
        .arlen(arlen),
        .arsize(arsize),
        .arburst(arburst),
        .arvalid(arvalid),

        .wdata(wdata),
        .wvalid(wvalid),
        .wlast(wlast),
        .bready(bready),

        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready)
    );

    AXI_SLAVE uut_slave (
        .aclk(aclk),
        .aresetn(aresetn),
        
        .input_re_data  (input_re_data),
        .awaddr(awaddr),
        .awsize(awsize),
        .awburst(awburst),
        .awlen(awlen),
        .awvalid(awvalid),
        .awready(awready),

        .wdata(wdata),
        .wvalid(wvalid),
        .wlast(wlast),
        .wready(wready),

        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),

        .input_re_addr  (input_re_addr),
        .input_re_len   (input_re_len),
        .input_re_size  (input_re_size),
        .input_re_burst (input_re_burst),
        .input_re_arvalid(input_re_arvalid),
        .arready(arready),
        .arvalid(arvalid),

        .rdata(rdata),
        .rresp(rresp),
        .rvalid(rvalid),
        .rlast(rlast),
        .rready(rready)
    );
    initial begin
        aclk = 0;
        forever #5  aclk = ~aclk; // 100MHz
    end
    // Test scenario
    initial begin
        // Init
        aresetn = 0;
        #10;
        aresetn = 1;

//        WRITE
//          Testcase 1: FIXED
//            Case 1: awlen = 1 beat, awsize = 1 byte
//        input_wr_addr  = 32'd0000_1235;
//        input_wr_len   = 2'b0;         // 1 beat
//        input_wr_size  = 3'b000;       // 1 bytes/beat 
//        input_wr_burst = 2'b00;        // FIXED burst
//        input_wr_data  = 32'h12345678;

//              Case 2: awlen = 4 beat , awsize = 2 byte
//        input_wr_addr  = 32'd0000_0016;
//        input_wr_len   = 8'd3;         // 4 beat (0~3)
//        input_wr_size  = 3'b001;       // 2 bytes/beat 
//        input_wr_burst = 2'b00;        // FIXED burst
//        input_wr_data  = 32'h12345678;

//              Case 3: awlen = 1 beat , awsize = 4 byte
//        input_wr_addr  = 32'd0000_106;
//        input_wr_len   = 8'd2;         // 3 beat (0~3)
//        input_wr_size  = 3'b010;       // 4 bytes/beat 
//        input_wr_burst = 2'b00;        // FIXED burst
//        input_wr_data  = 32'h12345678;

//          Testcase 2: INCR
//              Case 1: awlen = 3 beat, awsize = 2 byte
//        input_wr_addr  = 32'd0000_5000;
//        input_wr_len   = 2'b10;         // 3 beat
//        input_wr_size  = 3'b001;       // 2 bytes/beat 
//        input_wr_burst = 2'b01;        // INCR burst
//        input_wr_data  = 32'h22161043;
        
//              Case 2: awlen = 3 beat, awsize = 4 byte
//        input_wr_addr  = 32'd0000_2578;
//        input_wr_len   = 2'b10;         // 3 beat
//        input_wr_size  = 3'b010;       // 4 bytes/beat 
//        input_wr_burst = 2'b01;        // INCR burst
//        input_wr_data  = 32'h22161043;
        
//          Testcase 3: WRAP
//              Case 1: awlen = 14 beat, awsize = 1 byte
//        input_wr_addr  = 32'd0000_2578;
//        input_wr_len   = 4'b1101;         // 14 beat
//        input_wr_size  = 3'b000;       // 1 bytes/beat 
//        input_wr_burst = 2'b10;        // WRAP burst
//        input_wr_data  = 32'h45679123;

//              Case 2: awlen = 11 beat, awsize = 4 byte
//        input_wr_addr  = 32'd0001_5000;
//        input_wr_len   = 8'b0000_1010;         // 11 beat
//        input_wr_size  = 3'b010;       // 4 bytes/beat 
//        input_wr_burst = 2'b10;        // WRAP burst
//        input_wr_data  = 32'h45679123;

//          Testcase 4: FIXED, awlen = 1 beat , awsize = 4 byte, error address
//        input_wr_addr  = 15'd20000;
//        input_wr_len   = 8'd0;         // 1 beat 
//        input_wr_size  = 3'b001;       // 4 bytes/beat 
//        input_wr_burst = 2'b00;        // FIXED burst
//        input_wr_data  = 32'h12345678;
        
//        input_wr_valid = 1;
//        forever #100 input_wr_valid = ~input_wr_valid;

//        READ
//          Testcase 1: FIXED
//              Case 1: arlen = 1 beat, arsize = 1 byte
//        input_re_addr  = 32'd0001_5000;
//        input_re_len   = 8'b0000_0000;         // 1 beat
//        input_re_size  = 3'b000;       // 1 bytes/beat 
//        input_re_burst = 2'b00;        // FIXED burst
//        input_re_data  = 32'h45679123;
        
//              Case 2: arlen = 4 beat, arsize = 2 byte
//        input_re_addr  = 32'd0001_5000;
//        input_re_len   = 8'd3;         // 4 beat
//        input_re_size  = 3'b001;       // 2 bytes/beat 
//        input_re_burst = 2'b00;        // FIXED burst
//        input_re_data  = 32'h45679123;

//          Testcase 2: INCR
//              Case 1: arlen = 3 beat, arsize = 2 byte
//        input_re_addr  = 32'd0000_5000;
//        input_re_len   = 2'b10;         // 3 beat
//        input_re_size  = 3'b001;       // 2 bytes/beat 
//        input_re_burst = 2'b01;        // INCR burst
//        input_re_data  = 32'h87654321;
        
//              Case 2: arlen = 3 beat, arsize = 4 byte
//        input_re_addr  = 32'd0000_2578;
//        input_re_len   = 2'b10;         // 3 beat
//        input_re_size  = 3'b010;       // 4 bytes/beat
//        input_re_burst = 2'b01;        // INCR burst
//        input_re_data  = 32'h87654321;

//          Testcase 3: WRAP
//              Case 1: arlen = 14 beat, arsize = 1 byte
//        input_re_addr  = 32'd0000_2578;
//        input_re_len   = 4'b1101;         // 14 beat
//        input_re_size  = 3'b000;       // 1 bytes/beat 
//        input_re_burst = 2'b10;        // WRAP burst
//        input_re_data  = 32'h56217895;

//              Case 2: arlen = 11 beat, arsize = 4 byte
//        input_re_addr  = 32'd0001_5000;
//        input_re_len   = 8'b0000_1010;         // 11 beat
//        input_re_size  = 3'b010;       // 4 bytes/beat 
//        input_re_burst = 2'b10;        // WRAP burst
//        input_re_data  = 32'h56217895;
        
//          Testcase 4: FIXED, arlen = 1 beat , arsize = 4 byte, error address
        input_re_addr  = 15'd20000;
        input_re_len   = 8'd0;         // 1 beat 
        input_re_size  = 3'b001;       // 4 bytes/beat 
        input_re_burst = 2'b00;        // FIXED burst
        input_re_data  = 32'h12345678;
        
        input_re_arvalid = 1;
        forever #100 input_re_arvalid = ~input_re_arvalid;
    end

endmodule
