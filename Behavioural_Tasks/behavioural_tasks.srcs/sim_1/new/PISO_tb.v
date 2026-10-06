`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 12:08:39
// Design Name: 
// Module Name: PISO_tb
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


module PISO_tb();

    reg clk,rst,load;
    reg [3:0]p_in;
    wire s_out;
    
    PISO dut (clk,rst,load,p_in,s_out);
    initial
        begin
        {clk,rst,load,p_in}=0;
        end
         
        always #5 clk = ~clk;
        initial
        begin
        rst = 1;
        #10;
        rst = 0;
        #10;
        p_in = 4'b0101;
        load = 1'b1;
        
        #20;
        load =1'b0;
        end

endmodule
