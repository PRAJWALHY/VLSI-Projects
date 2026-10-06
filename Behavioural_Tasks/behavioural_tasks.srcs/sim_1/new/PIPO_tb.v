`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 12:41:15
// Design Name: 
// Module Name: PIPO_tb
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


module PIPO_tb( );

reg clk,rst,load;
reg [3:0] p_in;
wire [3:0] p_out;

PIPO dut (clk,rst,load,p_in,p_out);
    initial 
    begin 
    {clk,rst,load,p_in}=0;
    end
    always #5 clk = ~clk;
    initial 
    begin
    rst =1;
    #10;
    rst = 0;
    #10;
     p_in = 4'b1011;
     load = 1'b1;
     #30;
     load=0;
     end

endmodule
