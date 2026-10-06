`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 18:31:37
// Design Name: 
// Module Name: SISO
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


/*module SISO(input clk,rst,s_in,enb,output reg s_out);
    reg [3:0] temp;
    always @(posedge clk)
        begin
            if (rst)
                temp <= 4'b0000;
            else if (enb)
                begin
                temp <= temp >> 1'b1;
                temp [3] = s_in;
                s_out <= temp[0];
                end
         end
endmodule */


/*`timescale 1ns/1ps

module SISO(
    input clk,
    input rst,
    input sin,
    output reg sout
);

reg [3:0] shift;

always @(posedge clk)
begin
    if(rst)
    begin
        shift <= 4'b0000;
        sout  <= 1'b0;
    end
    else
    begin
        shift <= {shift[2:0], sin};
        sout  <= shift[3];
    end
end

endmodule */

/// siso using concatinaton in right shift

/*module SISO(input clk,rst,s_in,enb,output reg s_out);
    reg [3:0] temp;
    always @(posedge clk)
        begin
            if (rst)
                temp <= 4'b0000;
            else if (enb)
                begin
                temp <={s_in,temp[3:1]};
                temp [3] <= s_in;
                s_out <= temp [0];
                end
                end
                endmodule */
                
                
/// siso using concatiation in left shift

module SISO(input clk,rst,s_in,enb,output reg s_out);
    reg [3:0] temp;
    always @(posedge clk)
        begin
            if (rst)
                temp <= 4'b0000;
            else if (enb)
                begin
                temp <={temp[2:0],s_in};
                
                s_out <= temp [3];
                end
                end
                endmodule
                



