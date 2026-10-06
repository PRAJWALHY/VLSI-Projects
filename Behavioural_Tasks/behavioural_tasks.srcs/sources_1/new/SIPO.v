`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 11:18:39
// Design Name: 
// Module Name: SIPO
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


module SIPO(
input clk,rst,enb,s_in,output reg [3:0] temp);
    
    reg [3:0] p_out;
    
    always @(posedge clk)
        if (rst)
        begin 
        temp<= 4'b0000;
        end
        
        else if (enb == 0)
        begin
        temp<= temp >> 1'b1;
        temp [3] <= s_in;
        end
        else if (enb ==1)
        begin
        p_out <= temp;
        end
   
endmodule


