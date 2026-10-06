`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 11:23:57
// Design Name: 
// Module Name: SIPO_tb
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


module SIPO_tb();

    reg clk,rst,enb,s_in;
    wire  [3:0] p_out;
    
    SIPO dut (clk,rst,enb,s_in,p_out);
    initial
    begin
        {clk,rst,enb,s_in}=0;
        end
        always #5 clk = ~clk;
        initial 
            begin
             rst= 1;
             #10;
             rst =0;
             #10;
             
             s_in = 1'b1;
             #10;
             s_in = 1'b1;
             #10;
             s_in = 1'b0;
             #10;
             s_in = 1'b1;
             #10;
             
             enb =1;
             
             end
    
endmodule
