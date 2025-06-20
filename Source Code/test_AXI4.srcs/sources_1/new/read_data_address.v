`timescale 1ns / 1ps

module read_data_address(
    input wire          aclk,
    input wire          aresetn,

    input wire [15:0]   input_re_addr,
    input wire [7:0]    input_re_len,
    input wire [2:0]    input_re_size,
    input wire [1:0]    input_re_burst,
    input wire          input_re_arvalid,
    output reg          arready,
    input wire          arvalid,
    input wire [31:0]   input_re_data,
    
    output reg [31:0]   rdata,
    output reg [1:0]    rresp,
    output reg          rlast,
    output reg          rvalid,
    input wire          rready
    );
    localparam RE_IDLE = 2'b00, 
               RE_DATA = 2'b01, 
               RE_RS = 2'b10;
   localparam  FIXED   = 2'b00, 
               INCR = 2'b01, 
               WRAP = 2'b10;

    localparam width1  = 3'b000, 
               width2 = 3'b001, 
               width3 = 3'b010;
;
    reg [7:0]  re_scnt = 0;
    reg [1:0] re_st;
    reg [15:0] wrap_boundary, address_n;
    
    always @(posedge aclk or negedge aresetn) 
    begin
        if (!aresetn) 
        begin
            arready <= 0;
            rresp   <= 2'bx; // NONE
            rdata   <= 32'bx;
            rvalid  <= 0;
            rlast   <= 0;
            re_scnt  <= 0;
            re_st    <= RE_IDLE;
        end 
        else begin
            case (re_st)
                RE_IDLE: begin
                             if (arvalid) 
                             begin
                                arready <= 1;
                                rresp <= 2'bx;
                                if (input_re_burst == WRAP) 
                                begin
                                    wrap_boundary = (input_re_addr / ((input_re_len + 1) * (1 << input_re_size))) * ((input_re_len + 1) * (1 << input_re_size));
                                    address_n = wrap_boundary + ((input_re_len + 1) * (1 << input_re_size));
                                end
                                re_scnt  <= 0;
                                rvalid   <= 0;
                                rlast    <= 0;
                                re_st    <= RE_DATA;
                            end
                            
                         end
                RE_DATA: begin
                             arready <= 0;
                             rvalid = 1;
                             if (rvalid && rready)
                             begin
                                   if (input_re_addr > 14'd16383) rresp <=  2'b10;
                                   else
                                   begin
                                       case (input_re_size)
                                            width1:  rdata <= {24'b0,input_re_data[7:0]}; 
                                            width2:  rdata <= {16'b0,input_re_data[15:0]}; 
                                            width3:  rdata <= input_re_data; 
                                            default: rdata <= input_re_data; 
                                       endcase
                                       rresp <=  2'b00;
                                    end 
                                    re_scnt <= re_scnt + 1;
                             end
                             if (re_scnt == input_re_len )
                             begin            
                                    rlast <= 1;
                                    re_scnt <= 0;
                                    re_st <= RE_RS;
                             end
                        end
                RE_RS: begin
                        rlast  <= 0;
                        rvalid <= 0;
                        rdata = 32'bx;
                        rresp  <= 2'bx;
                      end
                default: re_st <= RE_IDLE;          
            endcase
      end
    end
endmodule

