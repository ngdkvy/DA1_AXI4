`timescale 1ns / 1ps

module read_data(
    input wire          aclk,
    input wire          aresetn,
    
    input wire [15:0]   input_re_addr,
    input wire [7:0]    input_re_len,
    input wire [2:0]    input_re_size,
    input wire [1:0]    input_re_burst,

    input  wire [31:0]  rdata,
    input  wire [1:0]   rresp,
    input  wire         rlast,
    input  wire         rvalid,
    output reg          rready

    );
    localparam RE_IDLE = 2'b00,
               RE_ADDR = 2'b01,
               RE_SENT = 2'b10,
               RE_RS   = 2'b11;
    localparam FIXED   = 2'b00, 
               INCR    = 2'b01,
               WRAP    = 2'b10;
    localparam  width1 = 3'b000, 
                width2 = 3'b001, 
                width3 = 3'b010;

    reg [31:0] mem_master [0:16383];
    reg [7:0]  re_cnt = 0;
    reg [7:0]  re_data;
    reg [15:0] temp_addr;
    reg [15:0] wrap_boundary, address_n;
    
        always @(posedge aclk or negedge aresetn) 
    begin
        if (!aresetn) 
        begin
            rready   <= 0;
            re_cnt <= -1;
            re_data <= RE_IDLE;
        end
        else 
            case (re_data)      
                RE_IDLE: begin
                            rready   <= 0;
                            re_cnt <= -1;
                            if (input_re_burst == WRAP) 
                            begin
                                wrap_boundary = (input_re_addr / ((input_re_len + 1) * (1 << input_re_size))) * ((input_re_len + 1) * (1 << input_re_size));
                                address_n = wrap_boundary + ((input_re_len + 1) * (1 << input_re_size));
                            end
                            temp_addr <= input_re_addr;
                            re_data <= RE_SENT;
                         end  
                RE_SENT: begin
                            rready   = 1;
                            if (rvalid && rready) 
                            begin
                                case (input_re_burst)
                                     FIXED: mem_master[input_re_addr] = rdata;   
                                     INCR: begin
                                            mem_master[temp_addr] = rdata;
                                            case (input_re_size)
                                            width1:  temp_addr <= temp_addr + 1;
                                            width2:  temp_addr <= temp_addr + 2;
                                            width3:  temp_addr <= temp_addr + 4;
                                            default: temp_addr <= temp_addr + 1;
                                            endcase
                                           end
                                      WRAP: begin
                                                mem_master[temp_addr] = rdata;
                                                case (input_re_size)
                                                    width1:  temp_addr <= temp_addr + 1;
                                                    width2:  temp_addr <= temp_addr + 2;
                                                    width3:  temp_addr <= temp_addr + 4;
                                                    default: temp_addr <= temp_addr + 1;
                                                endcase
                                                if ((temp_addr + (1 << input_re_size)) >= address_n)
                                                    temp_addr <= wrap_boundary;
                                                else
                                                    temp_addr <= temp_addr + (1 << input_re_size);
                                            end
                                     default: mem_master[input_re_addr] = rdata;
                                endcase
                                re_cnt <= re_cnt + 1;
                                if ((re_cnt == input_re_len - 1) || (!input_re_len)) 
                                begin
                                    re_cnt <= 0;
                                    rready <= 0;
                                    re_data <= RE_RS;
                                end
                            end
                          end
                RE_RS: rready <= 0;
                default: rready <= 0;
            endcase
    end 
endmodule
