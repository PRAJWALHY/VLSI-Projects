`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 17:32:40
// Design Name: 
// Module Name: D_flipflop_tb
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


module D_flipflop_tb();

    reg clk,rst,d;
    wire q,qbar;
    
    D_flipflop dut (clk,rst,d,q,qbar);
    
    initial 
        begin 
        clk = 0;
        
        forever #5 clk = ~clk;
        end
        
        initial 
            begin 
            rst =1;
            d = 0;
            
            #10;
            
            rst=0;
            
            d=0;#10;
            d=1;#10;
            d=0;#10;
            d=1;#10;
            d=0;#10;
         $finish;
   
   end 
endmodule
