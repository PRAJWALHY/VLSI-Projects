`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 12:26:57
// Design Name: 
// Module Name: PIPO
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


module PIPO(input clk ,rst,load,input [3:0] p_in,output reg [3:0] p_out);
    
    reg [3:0] temp;
       
       always @(posedge clk)  begin
            if (rst)
                begin
                    temp <= 4'b0000;
                    end
                   else if (load)
                    temp <= p_in;
                   else if (load ==0)
                    p_out <= temp;
                   end   
endmodule
