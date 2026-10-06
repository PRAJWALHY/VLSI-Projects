`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 16:12:41
// Design Name: 
// Module Name: encoder_4_2_tb
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


module encoder_4_2_tb();
reg [3:0] din;
wire [1:0] y;

encoder_4_2 dut(din,y);
initial 
    begin
        {din}=0;
        end
       initial 
            begin 
                 din = 4'b0001; #10;
                 din = 4'b0010; #10;
                 din = 4'b0100; #10;
                 din = 4'b1000; #10;
                 end
                 
endmodule
