`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2026 10:49:58
// Design Name: 
// Module Name: dual_port_ram
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


module dual_port_ram(
    input clk_a,
    input clk_b,

    input en_a,
    input wr_a,
    input rd_a,
    input [2:0] addr_a,
    input [7:0] din_a,
    output reg [7:0] dout_a,

    input en_b,
    input wr_b,
    input rd_b,
    input [2:0] addr_b,
    input [7:0] din_b,
    output reg [7:0] dout_b
);

reg [7:0] mem [0:7];
integer i;

// Memory Initialization
initial
begin
    for(i=0;i<8;i=i+1)
        mem[i]=8'd0;

    dout_a=8'd0;
    dout_b=8'd0;
end

//---------------- Port A ----------------//

always @(posedge clk_a)
begin
    if(en_a)
    begin
        if(wr_a)
            mem[addr_a] <= din_a;

        else if(rd_a)
            dout_a <= mem[addr_a];
    end
end

//---------------- Port B ----------------//

always @(posedge clk_b)
begin
    if(en_b)
    begin
        if(wr_b)
            mem[addr_b] <= din_b;

        else if(rd_b)
            dout_b <= mem[addr_b];
    end
end

endmodule
