`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2026 11:44:15
// Design Name: 
// Module Name: Full_sub_using_half_sub
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


module Full_sub_using_half_sub(
        input  a,b,bin,output diff,borrow);
        wire d1;
        wire b1;
        wire b2;
        
  Half_sub hs1 (a,b,d1,b1);
  Half_sub hs2 (d1,bin,diff,b2);
  
  assign borrow = b1|b2;
endmodule
