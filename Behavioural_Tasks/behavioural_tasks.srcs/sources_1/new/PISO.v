`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 10:29:28
// Design Name: 
// Module Name: PISO
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


module PISO(input clk,rst,load,input [3:0] p_in,output reg s_out );

reg [3:0] temp;
always @(posedge clk)
    begin
        if (rst)
        temp <= 4'b0000;
        
        else
         if(load)
            temp <= p_in;
           else if (load == 0)
            begin
            temp <= {1'b0,temp[3:1]};
            s_out <= temp[0];
            end
            end   
endmodule
