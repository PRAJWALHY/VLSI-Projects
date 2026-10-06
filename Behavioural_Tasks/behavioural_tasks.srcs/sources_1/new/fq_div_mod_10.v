`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2026 16:07:31
// Design Name: 
// Module Name: fq_div_mod_10
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

module fq_div_mod_10 (
    input  clk,
    input  rst,
    input  enb,
    output f_out
);

    reg [3:0] count;
    reg enb1, enb2;

    // MOD-10 Counter
    always @(posedge clk)
    begin
        if (rst)
            count <= 4'd0;
        else if (enb && count == 4'd9)
            count <= 4'd0;
        else if (enb)
            count <= count + 1'b1;
    end

    // Positive edge enable
    always @(posedge clk)
    begin
        if (rst)
            enb1 <= 1'b0;
        else if (count <= 4'd6)
            #2 enb1 <= 1'b1;
        else
           #2  enb1 <= 1'b0;
    end

    // Negative edge enable
    always @(negedge clk)
    begin
        if (rst)
            enb2 <= 1'b0;
        else if (count <= 4'd6)
            #2 enb2 <= 1'b1;
        else
            #2 enb2 <= 1'b0;
    end

    assign f_out = enb1 | enb2;

endmodule