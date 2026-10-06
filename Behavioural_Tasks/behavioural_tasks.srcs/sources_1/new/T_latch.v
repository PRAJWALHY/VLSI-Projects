`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 15:03:51
// Design Name: 
// Module Name: T_latch
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


module T_latch( input enb,rst,t_in,output  reg q,qbar );

    always @(enb)
    if (enb) 
        if(rst)
            begin
            q <= 1'b0;
            qbar <= 1'b1;
            end
            
            else if (t_in ==0) begin
               q <=q;
               qbar <= qbar;
               end
            else if (t_in == 1'b1) begin
            q <= ~q;
            qbar <= ~qbar;
            
            end
endmodule 



































/*module T_latch(
    input enb,
    input rst,
    input t_in,
    output reg q,
    output qbar
);

assign qbar = ~q;

always @(*)
begin
    if (rst)
        q = 1'b0;
    else if (enb)
    begin
        if (t_in)
            q = ~q;
        else
            q = q;
    end
end

endmodule */

