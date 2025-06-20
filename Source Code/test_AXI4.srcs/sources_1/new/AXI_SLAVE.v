`timescale 1ns / 1ps

module AXI_SLAVE (
    input  wire         aclk,
    input  wire         aresetn,

    input wire [31:0]   input_re_data,
    
    // WRITE ADDRESS CHANNEL
    input  wire [15:0]  awaddr,
    input  wire [7:0]   awlen,
    input  wire [2:0]   awsize,
    input  wire [1:0]   awburst,
    input  wire         awvalid,
    output wire         awready,

    // WRITE DATA CHANNEL
    input  wire [31:0]  wdata,
    input  wire         wlast,
    input  wire         wvalid,
    output wire         wready,

    // WRITE RESPONSE CHANNEL
    output wire [1:0]   bresp,
    output wire         bvalid,
    input  wire         bready,

    // READ ADDRESS CHANNEL
    input wire [15:0]   input_re_addr,   
    input wire [7:0]    input_re_len,    
    input wire [2:0]    input_re_size,   
    input wire [1:0]    input_re_burst,  
    input wire          input_re_arvalid,
    output wire         arready,
    input wire          arvalid,
    // READ DATA CHANNEL
    output wire [31:0]  rdata,
    output wire [1:0]   rresp,
    output wire         rlast,
    output wire         rvalid,
    input  wire         rready
);

    // Signal to connect write memory to read memory
    wire [31:0] mem_data_out;

    // Instantiate write module
    write_data_address u_write (
        .aclk       (aclk),
        .aresetn    (aresetn),
        .awaddr     (awaddr),
        .awlen      (awlen),
        .awsize     (awsize),
        .awburst    (awburst),
        .awvalid    (awvalid),
        .awready    (awready),
        .wdata      (wdata),
        .wlast      (wlast),
        .wvalid     (wvalid),
        .wready     (wready),
        .bresp      (bresp),
        .bvalid     (bvalid),
        .bready     (bready)
    );

    // Instantiate read module
    read_data_address u_read (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .input_re_addr  (input_re_addr),
        .input_re_len   (input_re_len),
        .input_re_size  (input_re_size),
        .input_re_burst (input_re_burst),
        .input_re_arvalid(input_re_arvalid),
        .arready        (arready), 
        .arvalid        (arvalid),            
        .input_re_data  (input_re_data),        // t?m th?i k?t n?i wdata, c?n k?t n?i ?úng RAM
        .rdata          (rdata),
        .rresp          (rresp),
        .rlast          (rlast),
        .rvalid         (rvalid),
        .rready         (rready)
    );

endmodule
