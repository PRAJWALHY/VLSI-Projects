`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2026 16:04:50
// Design Name: 
// Module Name: True_dual_port_RAM_tb
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


module True_dual_port_RAM_tb();

    reg clk;

    // Port A
    reg enb_a;
    reg wr_a;
    reg [2:0] addr_a;
    reg [7:0] din_a;
    wire [7:0] dout_a;

    // Port B
    reg enb_b;
    reg wr_b;
    reg [2:0] addr_b;
    reg [7:0] din_b;
    wire [7:0] dout_b;

    
    true_dual_port_ram dut(
        .clk(clk),

        .enb_a(enb_a),
        .wr_a(wr_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),

        .enb_b(enb_b),
        .wr_b(wr_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    
    initial
        clk = 0;

    always #5 clk = ~clk;
    initial
    begin

        // Initialize all signals
        enb_a   = 0;
        wr_a   = 0;
        addr_a = 0;
        din_a  = 0;

        enb_b   = 0;
        wr_b   = 0;
        addr_b = 0;
        din_b  = 0;

        #10;

    
        // Test Case 1 : Port A Write
        
        enb_a   = 1;
        wr_a   = 1;
        addr_a = 3'd2;
        din_a  = 8'hAA;

        #10;

        
        // Test Case 2 : Port B Read
        
        enb_b   = 1;
        wr_b   = 0;
        addr_b = 3'd2;

        #10;

       
        // Test Case 3 : Port B Write
       
        wr_b   = 1;
        addr_b = 3'd5;
        din_b  = 8'h55;

        #10;

       
        // Test Case 4 : Port A Read
        
        wr_a   = 0;
        addr_a = 3'd5;

        #10;

        
        // Test Case 5 : Simultaneous Write
        // Different Addresses
       
        wr_a   = 1;
        addr_a = 3'd1;
        din_a  = 8'h11;

        wr_b   = 1;
        addr_b = 3'd6;
        din_b  = 8'h66;

        #10;

       
        // Test Case 6 : Simultaneous Read
       
        wr_a   = 0;
        wr_b   = 0;

        addr_a = 3'd1;
        addr_b = 3'd6;

        #10;

       
        // Test Case 7 : Read & Write Same Address
        
        wr_a   = 1;
        addr_a = 3'd4;
        din_a  = 8'h99;

        wr_b   = 0;
        addr_b = 3'd4;

        #10;

       
        // Test Case 8 : Write Collision
       
        wr_a   = 1;
        addr_a = 3'd7;
        din_a  = 8'hAA;

        wr_b   = 1;
        addr_b = 3'd7;
        din_b  = 8'h55;

        #10;
        
        wr_a = 0;
        wr_b=0;
        addr_a = 3'd7;
        addr_b = 3'd7;
        
        
        #10;
        



#100;
        $finish;

    end

endmodule
