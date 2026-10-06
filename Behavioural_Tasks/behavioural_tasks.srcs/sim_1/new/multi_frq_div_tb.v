`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 12:34:55
// Design Name: 
// Module Name: multi_frq_div_tb
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


module multi_frq_div_tb();
        reg clk,rst,enb;
        reg [1:0] mode;
        wire mod_2_count;
        wire f_2,f_4,f_8,f_16;
        
        multi_frq_div dut (clk,rst,enb,mode,f_2,f_4,f_8,f_16);
        initial
        begin
           {clk,rst,enb,mode}=0;
        end
        
        always #5clk = ~clk;
        initial
            begin
                rst=1;
                #10;
                rst = 0;
                #10;
                
                enb=1;
                mode = 2'b11;
                
                
                #500;
                
                enb=0;
                end  
        endmodule
