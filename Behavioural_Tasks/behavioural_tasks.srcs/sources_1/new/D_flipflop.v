`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 17:31:36
// Design Name: 
// Module Name: D_flipflop
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


module D_flipflop (input clk ,rst,d, output reg q,qbar);
     
    always@(negedge clk)
    
    begin
    if(rst)
        begin
            q <=1'b0;
            q <=1'b1;
          end
          else 
        begin
            q <= d;
            qbar <= ~d;
            end
       end
endmodule
