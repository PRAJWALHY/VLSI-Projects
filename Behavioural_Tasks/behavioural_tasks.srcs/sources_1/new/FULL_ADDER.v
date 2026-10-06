`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 17:18:25
// Design Name: 
// Module Name: FULL_ADDER
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


module full_adder (input a_fa,b_fa,cin_fa, output reg sum_fa,carry_fa
    );
    always @(*)
    begin
    sum_fa= (a_fa ^ b_fa ^ cin_fa);
    carry_fa = (a_fa & b_fa) | (a_fa & cin_fa) | (b_fa & cin_fa);
    end
endmodule
