`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2026 17:25:17
// Design Name: 
// Module Name: mod_b
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
module mod_b
        (input clk,
        rst,
        input[7:0]data_in,
        output reg[7:0] data_out,
        output reg rd_enb );    
        
    parameter idle = 2'b00;
    parameter s1 = 2'b01;
    parameter data_state = 2'b10;
    reg[1:0] ps,ns;  
    always@(posedge clk)
    begin
        if(rst)
            begin
                ps<=idle;
               end
         else 
            ps<=ns;
        end    
         always@(*) 
         begin
         ns= ps;
         rd_enb=1'b0;
            case(ps)
                idle: begin
                    ns=s1;
                    rd_enb=0;
                 end
               s1: begin
                    ns=data_state;
                  end 
               data_state: begin
                    ns=idle;
                    rd_enb=1;
                    end   
                    
                    default :
                    begin 
                        ns=idle;
                        rd_enb=0;
                        end
                  endcase
              end 
              always@(posedge clk)
              begin
                if(rst)
                    data_out <=0;
                else if (rd_enb)
                    data_out <= data_in;
               end   
endmodule


