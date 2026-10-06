`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 14:56:13
// Design Name: 
// Module Name: USR_tb
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


module USR_tb();
reg clk,rst,load,shift,s_in;
reg [1:0] mode;
reg [3:0] p_in;
wire s_out;
wire [3:0]p_out;

USR dut (clk,rst,load,shift,s_in,mode,p_in,s_out,p_out);
     initial 
     begin 
        {clk,rst,load,shift,s_in,mode,p_in} = 0;
     end 
     always #5 clk = ~clk;
     initial begin
     
            rst = 1'b1;
            #10;
            rst = 1'b0;
            #10;
            
            //siso_tb
            
            mode = 2'b00;
            shift=1'b1;
            
            s_in=1'b1;
            #10;
            s_in=1'b0;
            #10;
            s_in=1'b1;
            #10;
            s_in=1'b1;
            #50;
            
          shift = 1'b0;
          
          # 10;    //after some time 
          
          rst= 1'b1;
          #10;            //again reset it due to data in the reg
          rst=1'b0;
          
          mode=2'b01;
          shift = 1'b1;
          
            s_in=1'b1;
            #10;
            s_in=1'b0;
            #10;
            s_in=1'b1;
            #10;
            s_in=1'b1;
            #10;
            
            shift= 1'b0;
           #40;
           
           
           
           rst = 1'b1;  
           #10;                                    // again reset it
           rst = 1'b0;
           #10;
            
            // piso
         load =1'b1;
         mode=2'b10;
           p_in = 4'b1010;
           #10;
           load = 1'b0;
           
           
           rst = 1'b1;  
           #10;                                    // again reset it
           rst = 1'b0;
           #10;
            
            // pipo
         load =1'b1;
         mode=2'b11;
           p_in = 4'b0101;
           #10;
           load = 1'b0;
           
           end
         
            
            
         
            
            
            
     
                            
                    
endmodule
