`timescale 1ns / 1ps

//1: Error    
//0: Not error

module write_data(
    input wire          aclk,
    input wire          aresetn,

    input wire [7:0]    input_wr_len,
    input wire [2:0]    input_wr_size,
    input wire [31:0]   input_wr_data,
    
    input wire          aw_done,
    input  wire         wready,
    
    output reg [31:0]   wdata,
    output reg          wvalid,
    output reg          wlast
    );
   localparam WR_IDLE = 2'b00,
              WR_SENT = 2'b01,
              WR_RS   = 2'b10;
              
    reg [1:0]  wr_dt_state;
    reg [7:0]  wr_cnt = 0;
    
    always @(posedge aclk or negedge aresetn) 
    begin
        if (!aresetn) 
        begin
            wvalid = 0;
            wlast  = 0;
            wr_cnt = -1;     
            wdata  = 32'bx;
            wr_dt_state  <= WR_IDLE; 
        end 
        else 
            case (wr_dt_state)
                WR_IDLE: begin
                            wdata = 32'bx;
                            if ((aw_done) || (!aw_done))
                                wr_dt_state  <= WR_SENT; 
                         end
                WR_SENT: begin 
                            if (aw_done)
                            begin
                                wlast <= 1;
                                wvalid <= 1;
                                wr_dt_state <= WR_RS;
                            end
                            else if (!aw_done)
                            begin
                                wvalid = 1;
                                if (wvalid && wready)
                                begin
                                    case (input_wr_size)
                                        2'b00: wdata  <= {24'b0, input_wr_data[7:0]};
                                        2'b01: wdata  <= {16'b0, input_wr_data[15:0]};
                                        2'b10: wdata  <= input_wr_data;
                                        default: wdata <= input_wr_data;
                                    endcase
                                    wr_cnt = wr_cnt + 1; 
                                end
                                if (wr_cnt == input_wr_len)
                                begin            
                                    wlast = 1;
                                    wr_dt_state = WR_RS;
                                end
                            end
                        end
                WR_RS: begin
                        wlast  = 0;
                        wdata  = 32'bx;
                        wvalid = 0;
                       end
                default: wr_dt_state  = WR_IDLE; 
        endcase
    end
endmodule
