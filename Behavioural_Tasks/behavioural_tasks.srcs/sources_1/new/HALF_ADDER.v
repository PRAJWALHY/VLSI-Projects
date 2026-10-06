`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 16:45:58
// Design Name: 
// Module Name: HALF_ADDER
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


module HALF_ADDER( input a,b, output reg sum,carry);
    always @ (a,b)
    begin
            sum = a ^ b;
            carry = a & b;
        end
            
endmodule
