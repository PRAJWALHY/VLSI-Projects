`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2026 11:10:31
// Design Name: 
// Module Name: Half_sub
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


module Half_sub ( input a,b,output reg diff, borrow);
    always@(*)
        begin 
            diff=a^b;
            borrow =~a&b;
         end       
endmodule
