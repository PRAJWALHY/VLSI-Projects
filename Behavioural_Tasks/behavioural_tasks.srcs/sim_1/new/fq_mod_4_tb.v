`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 11:47:21
// Design Name: 
// Module Name: fq_mod_4_tb
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


module fq_mod_4_tb();
reg clk,rst,enb;
wire [1:0] count;
wire f4_out;


fq_mod_4 dut (clk,rst,enb,f4_out);

initial
  begin
    {clk,rst,enb}=0;
    end
    always #5 clk = ~ clk;
    initial
    begin
     rst=1;
     #10;
     rst =0;
     
     enb =1;
     #100;
     
     enb =0;
     
     end    
endmodule
