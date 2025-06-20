`timescale 1ns / 1ps

module tb_read_address;

    // Clock & reset
    reg aclk;
    reg aresetn;

    // Inputs to DUT
    reg [15:0] input_re_addr;
    reg [7:0]  input_re_len;
    reg [2:0]  input_re_size;
    reg [1:0]  input_re_burst;
    reg        input_re_arvalid;
    reg        arready;

    // Outputs from DUT
    wire [15:0] araddr;
    wire [7:0]  arlen;
    wire [2:0]  arsize;
    wire [1:0]  arburst;
    wire        arvalid;
    wire        ar_done;

    // Instantiate DUT
    read_address dut (
        .aclk(aclk),
        .aresetn(aresetn),
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
        .ar_done(ar_done)
    );

    // Clock generation: 10ns period
    initial aclk = 0;
    always #5 aclk = ~aclk;

    // Test sequence
    initial begin
        // Initial values
        aresetn = 0;

        // Reset pulse
        #12;
        aresetn = 1;
        arready = 1;
        // Send read address
        @(posedge aclk);
        input_re_addr = 16'd20000;        // < 0x3FFF, ar_done should be 0
        input_re_len  = 8'd4;
        input_re_size = 3'b010;          // 4 bytes
        input_re_burst = 2'b01;          // INCR
        input_re_arvalid = 1;

 
    end

endmodule
