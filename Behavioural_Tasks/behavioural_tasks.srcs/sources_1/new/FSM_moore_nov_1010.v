`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.07.2026 12:15:05
// Design Name: 
// Module Name: FSM_moore_nov_1010
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


module FSM_moore_nov_1010(
input clk,rst,din,output reg detected);
    parameter idle = 3'b000;
    parameter s1 = 3'b001;
    parameter s2 = 3'b010;
    parameter s3 = 3'b011;
    parameter s4 = 3'b100;
    reg [2:0] ps,ns;
    
    // present state logic asyc
    
    always@(posedge clk)
        begin
            if(rst) begin                                               // for sync u have to comment all the detecetd  signals
                ps<= idle;
                end
            else ps <= ns;
                end
                
     // next state logic asyc
     
     always@(*)
        begin 
        case(ps)
            idle: begin
             //   detected = 0;
            if (din == 1'b1)
                ns =s1;
            else 
                ns= idle;
            end 
            
            s1: begin
                if(din==1'b0)
                    ns=s2;
                else 
                    ns=s1;
                end
                
            s2: begin
                if(din == 1'b1)
                    ns= s3;
                else
                    ns=idle;
                end
                
             s3: begin
                if (din == 1'b1)
                    ns=s1;
                else begin
                    ns=s4;
               //     detected = 1'b1;
                end
               end
               s4: begin
              // detected = 1'b1;
                if(din == 1'b0)
                    ns= idle;
                else
                    ns = s1;
                end
               
               
               
              default :ns= idle;
              
              endcase   
              end
      // for sync  
              always @(posedge clk)
                begin if (rst)
                    detected <= 1'b0;
                  else 
                    case (ps)
                        idle: detected<=0;
                        s1: detected <=0;
                        s2:detected <=0;
                        s3: detected <=1'b0;
                        s4:detected <=1'b1;
                               
                            default: detected <=1'b0;
                           endcase
                           
                          end   

   
endmodule
