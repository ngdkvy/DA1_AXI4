`timescale 1ns / 1ps

module tb_read_data;

    reg aclk;
    reg aresetn;

    reg [15:0] input_re_addr;
    reg [7:0] input_re_len;
    reg [2:0] input_re_size;
    reg [1:0] input_re_burst;

    wire rready;
    reg [31:0] rdata;
    reg [1:0]  rresp;
    reg        rlast;
    reg        rvalid;

    // Instantiate the DUT
    read_data uut (
        .aclk(aclk),
        .aresetn(aresetn),
        .input_re_addr(input_re_addr),
        .input_re_len(input_re_len),
        .input_re_size(input_re_size),
        .input_re_burst(input_re_burst),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready)
    );

    // Clock generation
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end

    // Task: Send a burst of read data
    task send_read_burst(input [7:0] len, input [2:0] size, input [1:0] burst);
        integer i;
        begin
            input_re_len   = len;
            input_re_size  = size;
            input_re_burst = burst;
            input_re_addr  = 16'd100; // base address

            @(negedge aclk);
            aresetn = 1;

            for (i = 0; i <= len; i = i + 1) begin
                @(negedge aclk);
                rvalid = 1;
                rdata  = 32'hA000_0000 + i;
                rresp  = 2'b00;
                rlast  = (i == len);
                @(posedge aclk);
                while (!rready) @(posedge aclk); // wait for rready
            end

            @(negedge aclk);
            rvalid = 0;
            rlast  = 0;
        end
    endtask

    initial begin
        // Initial values
        aresetn = 0;
        rvalid  = 0;
        rdata   = 0;
        rresp   = 2'b00;
        rlast   = 0;

        // Wait then release reset
        #20;
        @(negedge aclk); aresetn = 1;

        #10;
        $display("---- START: FIXED burst ----");
        send_read_burst(4, 3'b010, 2'b00); // FIXED
        #50;

        $display("---- START: INCR burst ----");
        send_read_burst(4, 3'b010, 2'b01); // INCR
        #50;

        $display("---- START: WRAP burst ----");
        send_read_burst(4, 3'b010, 2'b10); // WRAP
        #50;

        $display("---- Simulation Finished ----");
        $finish;
    end

endmodule
