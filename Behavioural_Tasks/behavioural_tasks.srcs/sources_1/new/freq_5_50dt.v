`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 17:53:03
// Design Name: 
// Module Name: freq_5_50dt
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


module freq_5_50dt(input clk,rst,enb,output f_out);
        reg [4:0] count;
        reg enb1,enb2;
        //reg first_negedge;   //added
        
        always @(posedge clk)
        begin
            if (rst)
            begin
            count<=0;
            enb1<=0;
            enb2<=0;
           // first_negedge<=1'b1;  // added
            end
        else if(enb && count ==4)
                count=0;
        else if (enb && count <4)
                count = count + 1'b1;
          end
          
          
       always @(posedge clk)
            begin 
            if (count==0 || count ==1)
               enb1 <= 1'b1;
            else 
                enb1 <=1'b0;
                
              end
              
       always @(negedge clk)        
        begin
            if (count ==0 || count ==1)
                enb2 <=1'b1;
            else 
                enb2 <=1'b0;
            end
            
            assign f_out = enb1 | enb2;
          
endmodule
