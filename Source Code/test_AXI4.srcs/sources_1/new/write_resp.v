`timescale 1ns / 1ps

module write_response(
    input wire          aclk,
    input wire          aresetn,
    
    input wire        awready,
    
    input  wire [1:0]   bresp,
    input  wire         bvalid,
    output reg          bready
    

    );
    localparam WR_IDLE = 1'b0,
               WR_SENT = 1'b1;
               
    reg [1:0]  wr_res; 
    
    always @(posedge aclk or negedge aresetn) 
    begin
        if (!aresetn) 
        begin
            bready = 0;
            wr_res = WR_SENT;
        end
        else 
            case (wr_res)
                WR_IDLE: bready = 0;
                WR_SENT: begin 
                             if (awready)              bready = 1;
                             if  (bvalid)              bready = 0;
                         end
                default: wr_res <= WR_IDLE;
            endcase
    end

endmodule
