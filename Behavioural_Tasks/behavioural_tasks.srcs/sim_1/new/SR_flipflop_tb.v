`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 16:22:45
// Design Name: 
// Module Name: SR_flipflop_tb
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
/*module SR_flipflop_tb();
    reg clk,rst,s,r;
    wire q,qbar;
    
    SR_flipflop dut(clk,rst,s,r,q,qbar);
    initial 
        begin
            {clk,rst,s,r}=0;
           end
    always #5 clk = ~clk;
        initial 
         begin 
            rst = 1;#10;
            rst =0 ;
            
            // hold condition 
            
            s=0;r=0;#10;
            s=0;r=1;#10;
            s=1;r=0;#10;
            s=1;r=1;#10;
            
            end
endmodule */




module SR_flipflop_tb;

    reg clk;
    reg rst;
    reg s;
    reg r;

    wire q;
    wire qbar;

    // Instantiate the Design Under Test (DUT)
    SR_flipflop dut (
        .clk(clk),
        .rst(rst),
        .s(s),
        .r(r),
        .q(q),
        .qbar(qbar)
    );

    // Clock Generation
    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Apply Test Vectors
    initial
    begin
        // Initialize
        rst = 1;
        s = 0;
        r = 0;

        #10;

        // Release Reset
       rst = 0;

        // Hold
        s = 0; r = 0;
        #10;

        // Set
        s = 1; r = 0;
        #10;

        // Hold
        s = 0; r = 0;
        #10;

        // Reset
        s = 0; r = 1;
        #10;

        // Hold
        s = 0; r = 0;
        #10;

        // Invalid
        s = 1; r = 1;
        #10;

        $finish;
    end
endmodule