`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 12:17:52
// Design Name: 
// Module Name: multi_frq_div
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


module multi_frq_div(
               input clk,rst,enb,input [1:0]mode,
               output reg f_2,
               output reg f_4,
               output reg f_8,
               output reg f_16);
               
               reg [3:0] counter_interval;
        
        always@(posedge clk)
            begin
            if(rst)
                counter_interval<=0;
            else if (enb) 
                counter_interval<= counter_interval + 1'b1;
                
           else if (enb)
                   counter_interval<= counter_interval - 1'b1;
           else 
                 counter_interval <= counter_interval;   
                end
                always@(posedge clk)               
                    begin
                    case(mode)
                        2'b00: // mod_2
                          begin
                            f_2 <=counter_interval[0];
                          end
                       
                       2'b01: //  mod4
                         begin 
                            f_4<=counter_interval[1];
                         end 
                         
                       2'b10:
                          begin
                            f_8 <=counter_interval[2];
                          end
                          
                       2'b11:
                        begin
                            f_16 <=counter_interval[3];
                        end 
                         
                       default :
                        begin 
                        f_2 <= 0;
                        f_4 <= 0;
                        f_8 <= 0;
                        f_16 <= 0;
                        end
                  endcase
             end
endmodule

