`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2026 17:35:33
// Design Name: 
// Module Name: top_mod_fifo
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


module top_mod_fifo( input clk,rst,input [7:0] data_top,data_out_top );
    
    wire [7:0] data_out_temp;
    wire wr_enb,rd_enb;
    wire full,empty;
    wire [7:0]data_out_fifo;
    
    
    mod_a mod1(data_top,clk,rst,data_out_temp,wr_enb);
    
    FIFO_8X8 fifo(clk,rst,wr_enb,rd_enb,data_out_temp,data_out_fifo,full,empty);
    
    mod_b mod2(clk,rst,data_out_fifo,data_out_top,rd_enb);
    
   
endmodule
