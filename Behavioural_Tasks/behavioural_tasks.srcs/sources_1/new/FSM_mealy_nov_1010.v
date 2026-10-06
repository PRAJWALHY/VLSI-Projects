`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.07.2026 11:11:12
// Design Name: 
// Module Name: FSM_mealy_nov_1010
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


module FSM_mealy_nov_1010(
input clk,rst,din,output reg detected);
    parameter idle = 2'b00;
    parameter s1 = 2'b01;
    parameter s2 = 2'b10;
    parameter s3 = 2'b11;
    
    reg [1:0] ps,ns;
    
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
                    ns=idle;
               //     detected = 1'b1;
                end
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
                        s3: begin
                            if (din==1'b1)
                            detected <=1'b0;
                            else 
                                detected <=1'b1;
                                end
                            default: detected <=1'b0;
                           endcase
                           
                          end

endmodule
