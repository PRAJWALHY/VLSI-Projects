`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 11:35:20
// Design Name: 
// Module Name: fq_mod_4
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


module fq_mod_4(
    input clk,rst,enb,
    output f4_out);
    
    reg [1:0] count;
    
    always @(posedge clk)
      begin
       if (rst)
      begin
        count <=0;
        end
       else 
          if (enb)
          count <= count + 1'b1;
          
          else
            count <= count;
            end
          assign f4_out = count[1];
          
          endmodule
       
       
            

    

