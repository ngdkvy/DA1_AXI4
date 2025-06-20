`timescale 1ns / 1ps

//1: Error
//0: Not error

module write_address(
    input wire aclk,
    input wire aresetn,
    
    input wire [15:0]   input_wr_addr,
    input wire [7:0]    input_wr_len,
    input wire [2:0]    input_wr_size,
    input wire [1:0]    input_wr_burst,
    input wire          input_wr_valid,
    
    output reg [15:0] awaddr,
    output reg [7:0]  awlen,
    output reg [2:0]  awsize,
    output reg [1:0]  awburst,
    output reg        awvalid,
    input wire        awready,
    
    output reg aw_done = 1'bx
    );
    localparam WR_IDLE = 2'b00,
               WR_ADDR = 2'b01,
               WR_RS   = 2'b10;
    reg [1:0]  wr_state;
    always @(posedge aclk or negedge aresetn) 
    begin
        if (!aresetn) 
        begin
            awvalid  = 0;
            awlen    = 8'bx;
            awburst  = 2'bx;
            awsize   = 3'bx;
            awaddr   = 16'bx;
            aw_done  = 1'bx;
            wr_state = WR_IDLE;
        end
        else 
            case (wr_state)
                WR_IDLE: begin
                            awaddr   = 16'bx;
                            awlen    = 8'bx;
                            awsize   = 3'bx;
                            awburst  = 2'bx;
                            aw_done  = 1'bx;
                            wr_state = WR_ADDR;
                        end
                WR_ADDR: begin
                            awvalid  = input_wr_valid;
                            if (awvalid)
                            begin
                                awaddr   = input_wr_addr;
                                awlen    = input_wr_len;
                                awsize   = input_wr_size;
                                awburst  = input_wr_burst;
                                if (input_wr_addr > 14'h3FFF) begin
                                        aw_done = 1'b1;
                                end 
                                else aw_done = 1'b0;
                                if (awvalid && awready) 
                                begin
                                    awvalid  = 0;
                                    awaddr   = 16'bx;
                                    awlen    = 8'bx;
                                    awsize   = 3'bx;
                                    awburst  = 2'bx;
                                    wr_state = WR_RS;
                                end
                            end
                         end
                 WR_RS: awvalid = 0;
                default: wr_state  = WR_IDLE;
            endcase
        end

endmodule
