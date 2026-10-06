`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 16:53:41
// Design Name: 
// Module Name: half_adder_tb
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


module half_adder_tb;
    reg a_tb,b_tb;
    wire sum_tb,carry_tb;

    HALF_ADDER dut(a_tb,b_tb,sum_tb,carry_tb);
    
    initial 
        begin
            {a_tb,b_tb}= 2'b00;
        end
             
        initial 
        begin 
        a_tb =0; b_tb =0;#100
        a_tb =0; b_tb =1;#100
        a_tb =1; b_tb =0;#100
        a_tb =1; b_tb =1;#100
       
       $display ("the value of sum is %d and carry is %d" ,sum_tb,carry_tb);
    end
endmodule
