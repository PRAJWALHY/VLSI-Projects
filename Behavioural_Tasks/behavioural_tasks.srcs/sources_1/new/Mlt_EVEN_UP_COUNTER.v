`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 17:26:47
// Design Name: 
// Module Name: Mlt_EVEN_UP_COUNTER
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


module Mlt_EVEN_UP_COUNTER
              (input clk,rst,enb,input [1:0]mode,input up_downbar,
               output reg mod_2_count,
               output reg [1:0] mod_4_count,
               output reg [2:0] mod_8_count,
               output reg [3:0] mod_16_count  );

        reg [3:0] counter_interval;
        always@(posedge clk)
            begin
            if(rst)
                counter_interval<=0;
            else 
            if (enb && up_downbar)
                counter_interval<= counter_interval + 1'b1;
                
                else if (enb && ~up_downbar)
                    counter_interval<= counter_interval - 1'b1;
                    
                end
                always@(posedge clk)               
                    begin
                    case(mode)
                        2'b00: // mod_2
                          begin
                            mod_2_count<=counter_interval[0];
                          end
                       
                       2'b01: //  mod4
                         begin 
                            mod_4_count<=counter_interval[1:0];
                         end 
                         
                       2'b10:
                          begin
                            mod_8_count <=counter_interval[2:0];
                          end
                          
                       2'b11:
                        begin
                            mod_16_count<=counter_interval;
                        end 
                         
                       default :
                        begin 
                        mod_2_count <= 0;
                        mod_4_count <= 0;
                        mod_8_count <= 0;
                        mod_16_count <= 0;
                        end
                  endcase
             end
endmodule
