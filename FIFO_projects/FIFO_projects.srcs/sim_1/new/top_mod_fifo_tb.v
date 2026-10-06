`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2026 17:46:35
// Design Name: 
// Module Name: top_mod_fifo_tb
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


module top_mod_fifo_tb();
    reg clk,rst;
    reg [7:0]data_in;
    wire[7:0] data_out;
    
    top_mod_fifo dut(clk,rst,data_in,data_out);
    initial 
        begin
            {clk,rst,data_in}=0;
            end
            
       always #5 clk = ~clk;
       
       initial
          begin
                rst=1;
                #10;
                rst=0;
                #10;
                
                
                
                data_in=5;
                #10;
                data_in=10;
                #10;
                data_in=5;
                #10;
                
                
                
                #100;
                $finish;
                
                end
endmodule
