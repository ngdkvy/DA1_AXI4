`timescale 1ns / 1ps

module write_data_address(
    input wire          aclk,
    input wire          aresetn,

    // Kênh ??a ch? ghi
    input wire [15:0]   awaddr,
    input wire [7:0]    awlen,
    input wire [2:0]    awsize,
    input wire [1:0]    awburst,
    input wire          awvalid,
    output reg          awready,

    // Kênh d? li?u ghi
    input wire [31:0]   wdata,
    input wire          wlast,
    input wire          wvalid,
    output reg          wready,

    // Kênh ph?n h?i ghi
    output reg [1:0]    bresp,
    output reg          bvalid,
    input wire          bready
    );
    
    reg [31:0] mem_slave [0:16383];
    reg [15:0] wr_addr_reg;
    reg [7:0]  wr_awlen_reg;
    reg [7:0]  wr_awsize_reg;
    reg [1:0]  wr_burst_reg;
    reg [15:0] wrap_boundary, address_n;
    
    localparam WR_IDLE = 2'b00, 
               WR_DATA = 2'b01, 
               WR_RESP = 2'b10;
    localparam FIXED   = 2'b00, 
               INCR = 2'b01, 
               WRAP = 2'b10;
    
    reg [1:0] wr_st;
    reg [7:0] wr_cnt;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) 
        begin
            awready <= 0;
            wready  <= 0;
            bvalid  <= 0;
            bresp   <= 2'bx; // NONE
            wr_st <= WR_IDLE;
            wr_addr_reg   <= 0;
            wr_awlen_reg  <= 0;
            wr_awsize_reg <= 0;
            wr_burst_reg  <= 0;
        end 
        else 
        begin
            case (wr_st)
                WR_IDLE: begin
                             if (awvalid) 
                             begin
                                awready = 1;
                                bresp <= 2'bx;
                                wr_addr_reg   <= awaddr;
                                wr_burst_reg  <= awburst;
                                wr_awlen_reg  <= awlen;
                                wr_awsize_reg <= awsize;
                                if (awburst == WRAP) 
                                begin
                                    wrap_boundary = (awaddr / ((awlen + 1) * (1 << awsize))) * ((awlen + 1) * (1 << awsize));
                                    address_n = wrap_boundary + ((awlen + 1) * (1 << awsize));
                                end
                                wr_st <= WR_DATA;
                                wready <= 1;
                            end
                        end
                WR_DATA: begin
                            awready <= 0;
                            wready <= 1;
                            if (wvalid && wready) 
                            begin
                                case (wr_burst_reg)
                                     FIXED: mem_slave[wr_addr_reg] <= wdata;
                                     INCR: begin
                                            case (wr_awsize_reg)
                                                3'b000: begin
                                                            mem_slave[wr_addr_reg] <= {mem_slave[wr_addr_reg][31:8], wdata[7:0]};   // 1 byte
                                                            wr_addr_reg <= wr_addr_reg + 1;
                                                        end
                                                3'b001: begin
                                                            mem_slave[wr_addr_reg] <= {mem_slave[wr_addr_reg][31:16], wdata[15:0]};  // 2 byte
                                                            wr_addr_reg <= wr_addr_reg + 2;
                                                        end
                                                3'b010: begin
                                                            mem_slave[wr_addr_reg] <= wdata[31:0];                     // 4 byte
                                                            wr_addr_reg <= wr_addr_reg + 4;
                                                        end
                                                default: begin
                                                            mem_slave[wr_addr_reg] <= wdata; // fallback
                                                            wr_addr_reg <= wr_addr_reg + 4;
                                                         end
                                            endcase
                                           end
                                     WRAP: begin
                                            case (wr_awsize_reg)
                                                3'b000: begin
                                                            mem_slave[wr_addr_reg] <= {mem_slave[wr_addr_reg][31:8], wdata[7:0]};   // 1 byte
                                                            wr_addr_reg <= wr_addr_reg + 1;
                                                        end
                                                3'b001: begin
                                                            mem_slave[wr_addr_reg] <= {mem_slave[wr_addr_reg][31:16], wdata[15:0]};  // 2 byte
                                                            wr_addr_reg <= wr_addr_reg + 2;
                                                        end
                                                3'b010: begin
                                                            mem_slave[wr_addr_reg] <= wdata[31:0];                     // 4 byte
                                                            wr_addr_reg <= wr_addr_reg + 4;
                                                        end
                                                default:begin
                                                            mem_slave[wr_addr_reg] <= wdata; // fallback
                                                            wr_addr_reg <= wr_addr_reg + 4;
                                                        end
                                            endcase
                                                // N?u ??a ch? m?i v??t qua wrap boundary, reset v? wrap_boundary
                                            if ((wr_addr_reg + (1 << wr_awsize_reg)) >= address_n)
                                                wr_addr_reg <= wrap_boundary;
                                            else
                                                wr_addr_reg <= wr_addr_reg + (1 << wr_awsize_reg);
                                            end 
                                     default: wr_st <= WR_IDLE;    
                                endcase
                                wr_cnt <= wr_cnt + 1;
                                if (wr_cnt == wr_awlen_reg) 
                                begin
                                    wr_addr_reg <= 0;
                                    wr_cnt      <= 0;
                                end
                            end
                    if (wlast) 
                    begin
                        bresp  <= (wr_addr_reg > 14'd16383) ? 2'b11 : 2'b00;
                        bvalid <= 1;
                        wready <= 0;
                        wr_st <= WR_RESP;
                    end
                    end
                WR_RESP: begin
                            bvalid <= 0;
                            bresp <= 2'bx;
                            wr_st <= WR_IDLE;
                         end
               default: wr_st <= WR_IDLE;
            endcase
        end
    end

endmodule
