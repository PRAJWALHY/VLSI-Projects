`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 18:40:54
// Design Name: 
// Module Name: SISO_tb
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


module SISO_tb();

    reg clk,rst,s_in,enb;
    wire s_out;
    
    SISO dut(clk,rst,s_in,enb,s_out);
    
    initial 
        begin 
         {clk,rst,s_in,enb} =0  ;
         end
         always #5 clk= ~clk;
         initial
          begin
            rst =1; 
            #10;
            rst=0;
   
            enb=0;
            #10;
            enb=1;
            
            s_in=1'b1;
            #10;
            s_in=1'b0;
            #10;
            s_in=1'b1;
            #10;
            s_in=1'b1;
            #50;
            
            enb = 0;
            end     
endmodule  

/*`timescale 1ns/1ps

module SISO_tb;

reg clk;
reg rst;
reg sin;
wire sout;

SISO dut(clk, rst, sin, sout);

// Clock Generation
initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test Vectors
initial
begin
    rst = 1;
    sin = 0;

    #10;
    rst = 0;

    // Input serial data : 1 0 1 1
    sin = 1; #10;
    sin = 0; #10;
    sin = 1; #10;
    sin = 1; #10;

    // Continue clock to shift data out
    sin = 0; #10;
    sin = 0; #10;
    sin = 0; #10;
    sin = 0; #10;

    $finish;
end

// Monitor
initial
begin
    $monitor("Time=%0t clk=%b rst=%b sin=%b sout=%b",
             $time, clk, rst, sin, sout);
end

endmodule  */

















