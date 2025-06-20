`timescale 1ns / 1ps

module AXI_MASTER(
    input  wire         aclk,
    input  wire         aresetn,

    // INPUT CONTROL TO START WRITE TRANSACTION
    input  wire [15:0]  input_wr_addr,
    input  wire [7:0]   input_wr_len,
    input  wire [2:0]   input_wr_size,
    input  wire [1:0]   input_wr_burst,
    input  wire         input_wr_valid,
    input  wire [31:0]  input_wr_data,
    
    input wire [15:0]   input_re_addr,
    input wire [7:0]    input_re_len,
    input wire [2:0]    input_re_size,
    input wire [1:0]    input_re_burst,
    input wire          input_re_arvalid,

    // FROM SLAVE SIDE (AXI4)
    input  wire         awready,
    input  wire         wready,
    input  wire         bvalid,
    input  wire [1:0]   bresp,

    // TO SLAVE SIDE (AXI4)
    output wire [15:0]  awaddr,
    output wire [7:0]   awlen,
    output wire [2:0]   awsize,
    output wire [1:0]   awburst,
    output wire         awvalid,
    
    input  wire         arready,
    
    output wire [15:0]   araddr,
    output wire [7:0]    arlen,
    output wire [2:0]    arsize,
    output wire [1:0]    arburst,
    output wire          arvalid,

    output wire [31:0]  wdata,
    output wire         wvalid,
    output wire         wlast,
    
    output wire         bready,
    
    input  wire [31:0]  rdata,
    input  wire [1:0]   rresp,
    input  wire         rlast,
    input  wire         rvalid,
    output wire         rready
);

    // Internal signal
    wire aw_done_signal;
    wire ar_done_signal;
    
    // Module write_address
    write_address wr_addr_inst (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .input_wr_addr  (input_wr_addr),
        .input_wr_len   (input_wr_len),
        .input_wr_size  (input_wr_size),
        .input_wr_burst (input_wr_burst),
        .input_wr_valid (input_wr_valid),
        .awaddr         (awaddr),
        .awlen          (awlen),
        .awsize         (awsize),
        .awburst        (awburst),
        .awvalid        (awvalid),
        .awready        (awready),
        .aw_done        (aw_done_signal)
    );

    // Module write_data
    write_data wr_data_inst (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .input_wr_len   (input_wr_len),
        .input_wr_size  (input_wr_size),
        .input_wr_data  (input_wr_data),
        .aw_done        (aw_done_signal),
        .wready         (wready),
        .wdata          (wdata),
        .wvalid         (wvalid),
        .wlast          (wlast)
    );

    // Module write_response
    write_response wr_resp_inst (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .awready        (awready),
        .bresp          (bresp),
        .bvalid         (bvalid),
        .bready         (bready)
    );
    read_address re_addr_inst (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .input_re_addr  (input_re_addr),
        .input_re_len   (input_re_len),
        .input_re_size  (input_re_size),
        .input_re_burst (input_re_burst),
        .input_re_arvalid (input_re_arvalid),
        .araddr         (araddr),
        .arlen          (arlen),
        .arsize         (arsize),
        .arburst        (arburst),
        .arvalid        (arvalid),
        .arready        (arready),
        .ar_done        (ar_done_signal)
    );
    read_data re_data_inst (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .input_re_addr  (input_re_addr),
        .input_re_len   (input_re_len),
        .input_re_size  (input_re_size),
        .input_re_burst (input_re_burst),
        .rready         (rready),
        .rdata          (rdata),
        .rvalid         (rvalid),
        .rlast          (rlast),
        .rresp          (rresp)
    );

endmodule 
