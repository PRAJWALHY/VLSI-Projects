`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 11:25:39
// Design Name: 
// Module Name: fq_mod_2_tb
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


module fq_mod_2_tb();
    reg clk,rst;
    wire f2_out;
    
    fq_mod_2 dut (clk,rst,f2_out);
    
    initial 
        begin
            {clk,rst}=0;
            
            end
        always #5 clk = ~clk;
        initial
            begin
            rst =1'b1;
            #10;
            rst = 1'b0;
            
            end
endmodule
