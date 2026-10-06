`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2026 17:08:14
// Design Name: 
// Module Name: FIFO_8X8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module FIFO_8X8(
    input clk,rst,wr_enb,rd_enb,
    input [7:0] data_in,output reg [7:0] data_out,
    output full,empty );   
    reg [2:0] wr_ptr = 0;
    reg [2:0] rd_ptr = 0;    
    reg [7:0] mem [0:7];  
    integer i;
    always @(posedge clk)
        begin
            if(rst)
                begin
                    wr_ptr  <=0;
                    rd_ptr <=0;
                    data_out <=0;
                    for(i=0;i<8;i=i+1)
                        mem[i] <=0;
                    end
            else
                begin
             if (wr_enb && !full) 
             begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
                
                end
             if (rd_enb && !empty)
              begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr +1;
              
              end
            end
         end
      assign full= ((wr_ptr +1'b1)==rd_ptr) ? 1'b1 : 1'b0;
      assign empty = wr_ptr == rd_ptr;    
endmodule
