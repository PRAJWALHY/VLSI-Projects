`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2026 17:21:16
// Design Name: 
// Module Name: mod_a
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


module mod_a(
    input [7:0] data_in,input clk,rst,output reg [7:0] data_out,output reg wr_enb);
    
    always@(posedge clk)
    begin
        if(rst) begin
            data_out<=0;
            wr_enb = 0;
            end
            
         else begin
                data_out<=data_in;
                wr_enb=1;
                end
            end   
endmodule
