`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 17:43:28
// Design Name: 
// Module Name: Mlt_EVEN_UP_COUNTER_tb
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


module Mlt_EVEN_UP_COUNTER_tb();
        reg clk,rst,enb;
        reg [1:0] mode;
        reg up_downbar;
        wire mod_2_count;
        wire [1:0]mod_4_count;
        wire [2:0]mod_8_count;
        wire [3:0]mod_16_count;
        
        Mlt_EVEN_UP_COUNTER dut (clk,rst,enb,mode,up_downbar,mod_2_count,mod_4_count,mod_8_count,mod_16_count);
        
        initial
        begin
        {clk,rst,enb,mode,up_downbar}=0;
        end
        
        always #5clk = ~clk;
        initial
            begin
                rst=1;
                #10;
                rst = 0;
                #10;
                
                enb=1;
                up_downbar=1'b0;
                
                mode = 2'b10;
                #70;
                
                enb=0;
                end  
        endmodule
       
