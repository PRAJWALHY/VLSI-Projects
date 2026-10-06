`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2026 16:50:47
// Design Name: 
// Module Name: shallow_copy_tb
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


module shallow_copy_tb();

  packet p1,p2;
  initial 
    begin
  p1 =new(2,3,1);
      p1.display("first p1");
  
 // p2 =new(1,2,3);
  //p2.display("p2");
      
   //   p2 = p1;  // object assignmnet
     p2 = new p1;  // shallow copy
      
      p2.addr= 20;
      p2.data=30;
      p2.display("p2");
      p1.display("p1");
    end


    
endmodule
