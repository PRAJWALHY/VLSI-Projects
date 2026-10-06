`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 16:35:56
// Design Name: 
// Module Name: SR_latch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SR_latch( input enb,rst,s,r, output reg q, qbar);
    
    always @(enb,rst)                                                    // for syncronous only "enb" in always @(enb)
        begin    
        // asynchrous reset
        if (rst) begin                      // if (enb)  should be added of it
            q<=1'b0;
            qbar<=1'b1;
            end
            if (enb) begin                                                      
         /*   //reset // synchronous
          if(rst)
           begin
            q    <= 1'b0;
            qbar <= 1'b1;
           end */
           
           // hold condition
           
          if(s ==0 && r ==0)
           begin
            q    <= q;
            qbar <= qbar;
           end 
           // reset
           else if(s==0 && r==1)
           begin
            q    <= 1'b0;
            qbar <= 1'b1;
           end 
           // set 
          else if(s==1 && r ==0)
           begin
            q    <= 1'b1;
            qbar <= 1'b0;
           end 
           
           // invalid
           
           else if(s==1 && r ==1)
           begin
            q    <= 1'bx;
            qbar <= 1'bx;
           end 
    end
    end
endmodule
