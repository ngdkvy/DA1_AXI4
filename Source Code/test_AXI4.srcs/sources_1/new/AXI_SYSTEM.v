`timescale 1ns / 1ps
module AXI4_TOP (
    input wire aclk,
    input wire aresetn,

    // ?i?u khi?n t? bên ngoài ?? test master
    input  wire [15:0] input_wr_addr,
    input  wire [7:0]  input_wr_len,
    input  wire [2:0]  input_wr_size,
    input  wire [1:0]  input_wr_burst,
    input  wire        input_wr_valid,
    input  wire [31:0] input_wr_data,

    input  wire [15:0] input_re_addr,
    input  wire [7:0]  input_re_len,
    input  wire [2:0]  input_re_size,
    input  wire [1:0]  input_re_burst,
    input  wire        input_re_arvalid,

    output wire [31:0] output_read_data  // d? li?u ??c ???c t? slave
);

    // Tín hi?u AXI k?t n?i master <-> slave
    wire [15:0] awaddr;
    wire [7:0]  awlen;
    wire [2:0]  awsize;
    wire [1:0]  awburst;
    wire        awvalid;
    wire        awready;

    wire [31:0] wdata;
    wire        wvalid;
    wire        wlast;
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
    wire        rlast;
    wire        rvalid;
    wire        rready;

    // Master
    AXI_MASTER master_inst (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .input_wr_addr  (input_wr_addr),
        .input_wr_len   (input_wr_len),
        .input_wr_size  (input_wr_size),
        .input_wr_burst (input_wr_burst),
        .input_wr_valid (input_wr_valid),
        .input_wr_data  (input_wr_data),

        .input_re_addr  (input_re_addr),
        .input_re_len   (input_re_len),
        .input_re_size  (input_re_size),
        .input_re_burst (input_re_burst),
        .input_re_arvalid (input_re_arvalid),

        .awaddr         (awaddr),
        .awlen          (awlen),
        .awsize         (awsize),
        .awburst        (awburst),
        .awvalid        (awvalid),
        .awready        (awready),

        .wdata          (wdata),
        .wvalid         (wvalid),
        .wlast          (wlast),
        .wready         (wready),

        .bresp          (bresp),
        .bvalid         (bvalid),
        .bready         (bready),

        .araddr         (araddr),
        .arlen          (arlen),
        .arsize         (arsize),
        .arburst        (arburst),
        .arvalid        (arvalid),
        .arready        (arready),

        .rdata          (rdata),
        .rresp          (rresp),
        .rlast          (rlast),
        .rvalid         (rvalid),
        .rready         (rready)
    );

    // Slave
    AXI_SLAVE slave_inst (
        .aclk           (aclk),
        .aresetn        (aresetn),
        .input_re_data  (wdata),  // ?ây là tín hi?u n?i b? RAM - c?n thay b?ng RAM th?t n?u c?n

        .awaddr         (awaddr),
        .awlen          (awlen),
        .awsize         (awsize),
        .awburst        (awburst),
        .awvalid        (awvalid),
        .awready        (awready),

        .wdata          (wdata),
        .wlast          (wlast),
        .wvalid         (wvalid),
        .wready         (wready),

        .bresp          (bresp),
        .bvalid         (bvalid),
        .bready         (bready),

        .input_re_addr  (araddr),
        .input_re_len   (arlen),
        .input_re_size  (arsize),
        .input_re_burst (arburst),
        .input_re_arvalid (arvalid),
        .arready        (arready),
        .arvalid        (arvalid),  // slave không dùng nh?ng v?n c?n k?t n?i

        .rdata          (rdata),
        .rresp          (rresp),
        .rlast          (rlast),
        .rvalid         (rvalid),
        .rready         (rready)
    );

    assign output_read_data = rdata;

endmodule
