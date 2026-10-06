`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 11:24:35
// Design Name: 
// Module Name: fq_mod_2
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


module fq_mod_2(
    input clk,rst,
    output reg f2_out
    );
    
    always @(posedge clk)
    begin
        if(rst) 
            f2_out <= 0;
        else
            f2_out <= ~f2_out;
            
         end
            
            
endmodule
