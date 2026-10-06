`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2026 12:53:24
// Design Name: 
// Module Name: ripple_carry_adder_tb
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
module ripple_carry_adder_tb;
    reg [3:0] a_tb,b_tb;
    reg cin;
    wire [3:0] sum_tb;
    wire carry_tb;
    
    ripple_carry_adder_4bit dut (a_tb,b_tb,cin,sum_tb,carry_tb);
    initial 
            begin
            {a_tb,b_tb,cin}=0;
            end 
        initial
            begin
            
            a_tb=4'b0110;
            b_tb=4'b1110;
            cin=1'b1;
            
            $monitor("the value of sum_tb is %b and the value of cout is %b",sum_tb,carry_tb);
    end
endmodule
