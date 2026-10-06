`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 16:13:38
// Design Name: 
// Module Name: freq_3_50dt_tb
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


module freq_3_50dt_tb();

reg clk,rst,enb;
wire f_out;

freq_3_50dt dut (clk,rst,enb,f_out);

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
            
            #100;
            
            enb =1'b0;
            
            end
endmodule
