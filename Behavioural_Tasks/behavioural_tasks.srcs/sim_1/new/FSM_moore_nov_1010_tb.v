`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.07.2026 12:16:03
// Design Name: 
// Module Name: FSM_moore_nov_1010_tb
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


module FSM_moore_nov_1010_tb();
reg clk,rst,din;
    wire detected;
    
    FSM_moore_nov_1010 dut (clk,rst,din,detected);
        initial 
            begin 
            {clk,rst,din}=0;
            end
        always #5 clk = ~clk;
            initial 
                begin 
                    rst =1'b1;
                    #10;
                    rst = 1'b0;
                    #10;
                    
                    din=1'b1;
                    #10;
                    din=1'b0;
                    #10;
                    din=1'b1;
                    #10;
                    din=1'b0;
                    #10;
                    din=1'b0;
                    #10;
                    din=1'b1;
                    #10;
                    din=1'b0;
                    #10;
                    din=1'b1;
                    #10;
                    din=1'b0;
                    #10;
                    din=1'b1;
                    #10;
                    din=1'b0;
                    #10;
                    din=1'b1;
                    #10;
                    din=1'b0;
                    
                    
                    
                end
                   
        
    
endmodule


