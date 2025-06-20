`timescale 1ns / 1ps

module read_address(
    input wire          aclk,
    input wire          aresetn,

    input wire [15:0]   input_re_addr,
    input wire [7:0]    input_re_len,
    input wire [2:0]    input_re_size,
    input wire [1:0]    input_re_burst,
    input wire          input_re_arvalid,
    
    input  wire         arready,
    
    output reg [15:0]   araddr,
    output reg [7:0]    arlen,
    output reg [2:0]    arsize,
    output reg [1:0]    arburst,
    output reg          arvalid,
    
    output reg          ar_done = 1'bx    
    );
    localparam RE_IDLE = 2'b00,
               RE_ADDR = 2'b01,
               RE_SENT = 2'b10;
       
    reg [1:0]  re_state;
    
        always @(posedge aclk or negedge aresetn) 
    begin
        if (!aresetn) begin
            arvalid  <= 0;
            arlen    <= 8'bx;
            arburst  <= 2'bx;
            arsize   <= 3'bx;
            araddr   <= 16'bx;
            ar_done  = 1'bx;
            re_state <= RE_IDLE;
        end
        else 
            case (re_state)
                RE_IDLE: begin
                            araddr   <= 16'bx;
                            arlen    <= 8'bx;
                            arsize   <= 3'bx;
                            arburst  <= 2'bx;
                            ar_done  = 1'bx;
                            arvalid  <= 0;
                            re_state <= RE_ADDR;
                        end
                RE_ADDR: if (input_re_arvalid) 
                         begin
                            araddr   <= input_re_addr;
                            arlen    <= input_re_len;
                            arsize   <= input_re_size;
                            arburst  <= input_re_burst;
                            arvalid  <= input_re_arvalid;
                            if (input_re_addr > 14'h3FFF) begin
                                    ar_done = 1'b1;
                            end 
                            else
                                    ar_done = 1'b0;
                            re_state <= RE_SENT;
                         end
                RE_SENT: if (arvalid && arready) 
                         begin
                            arvalid  <= 0;
                            araddr   <= 32'bx;
                            arlen    <= 8'bx;
                            arsize   <= 3'bx;
                            arburst  <= 2'bx;
                         end
                default: re_state <= RE_IDLE;
            endcase
    end

endmodule
