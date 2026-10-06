`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2026 16:09:27
// Design Name: 
// Module Name: fq_div_mod_10_tb
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

module fq_div_mod_10_tb;
    reg clk,rst,enb;
    wire f_out;

fq_div_mod_10 dut (clk,rst,enb,f_out);

    initial
        begin
            {clk,rst,enb}=0;
        end
    always #5 clk =~clk;
        initial
            begin
            rst = 1'b1;
            #10;
            rst = 1'b0;
            #10;
            
            enb = 1'b1;
            
            #500;
            
            enb =1'b0;
            
            end
endmodule


