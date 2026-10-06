`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 16:47:18
// Design Name: 
// Module Name: SR_latch_tb
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


module SR_latch_tb();
    reg enb,rst,s,r;
    wire q,qbar;
    
    SR_latch dut(enb,rst,s,r,q,qbar);
    initial 
        begin
            {enb,rst,s,r}=0;
           end
    always #5 enb = ~enb;
        initial 
         begin 
            rst = 1;#10;
            rst =0 ;
            
            // hold condition 
            
            s=0;r=0;#10;
            s=0;r=1;#10;
            s=1;r=0;#10;
            s=1;r=1;#10;
            
            end
endmodule
