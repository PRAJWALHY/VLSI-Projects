`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 13:09:56
// Design Name: 
// Module Name: JK_latch_tb
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


module JK_latch_tb(  );

    reg enb ,rst,j,k;
    wire q,qbar;
    
    integer i;
  
    JK_latch dut (enb,rst,j,k,q,qbar);
    
    initial 
    begin
    {enb,rst,j,k} = 0;
    end
    always #5 enb =~ enb;
    
    initial 
    begin
    rst = 1'b1;
    #10;
    
    rst = 1'b0;    
    #10;
    
    for (i=0;i<4;i=i+1)begin
     #1; 
    {j,k}=i;
    end

    end
   
endmodule
