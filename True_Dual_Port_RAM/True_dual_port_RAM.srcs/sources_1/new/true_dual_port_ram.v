`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2026 14:42:23
// Design Name: 
// Module Name: true_dual_port_ram
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


module true_dual_port_ram(
    input clk,

    // Port A
    input enb_a,
    input wr_a,
    input [2:0] addr_a,
    input [7:0] din_a,
    output reg [7:0] dout_a,

    // Port B
    input enb_b,
    input wr_b,
    input [2:0] addr_b,
    input [7:0] din_b,
    output reg [7:0] dout_b
);

    // memory
    reg [7:0] mem [0:7];

    integer i;

    initial
    begin
        for(i=0; i<8; i=i+1)
            mem[i] = 8'h00;

        dout_a = 8'h00;
        dout_b = 8'h00;
    end
//port A
    always @(posedge clk)
    begin
        if(enb_a)
        begin
            if(wr_a)
                mem[addr_a] <= din_a;
            else
                dout_a <= mem[addr_a];
        end
    end
    // Port B
    
    always @(posedge clk)
    begin
        if(enb_b)
        begin
            if(wr_b)
                begin
                    if(!(enb_a && wr_a &&(addr_a == addr_b)))     // priortiy give here
                   mem[addr_b] <= din_b;
                end
            else
            
                dout_b <= mem[addr_b];
        end
    end

endmodule
