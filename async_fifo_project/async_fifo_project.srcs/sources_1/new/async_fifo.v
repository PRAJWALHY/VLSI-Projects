`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2025 19:28:07
// Design Name: 
// Module Name: async_fifo
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


// async_fifo.v
// Asynchronous FIFO (dual clock) with Gray-coded pointers
// Parameterized by DATA_WIDTH and ADDR_WIDTH
// Depth = 2^ADDR_WIDTH

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                     wr_clk,
    input  wire                     wr_rst_n,
    input  wire                     wr_en,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    output wire                     full,

    input  wire                     rd_clk,
    input  wire                     rd_rst_n,
    input  wire                     rd_en,
    output reg  [DATA_WIDTH-1:0]    rd_data,
    output wire                     empty,

    output wire [ADDR_WIDTH:0]      wr_count,
    output wire [ADDR_WIDTH:0]      rd_count
);

localparam DEPTH = (1 << ADDR_WIDTH);

// Memory array
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

// Write pointers
reg [ADDR_WIDTH:0] wr_ptr_bin;
reg [ADDR_WIDTH:0] wr_ptr_gray;

// Read pointers
reg [ADDR_WIDTH:0] rd_ptr_bin;
reg [ADDR_WIDTH:0] rd_ptr_gray;

// Cross-domain synchronizers
reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

// Binary to Gray
function [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] b);
    bin2gray = (b >> 1) ^ b;
endfunction

// Gray to Binary
function [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] g);
    integer j;
    reg [ADDR_WIDTH:0] b;
    begin
        b[ADDR_WIDTH] = g[ADDR_WIDTH];
        for (j = ADDR_WIDTH-1; j >= 0; j = j-1)
            b[j] = b[j+1] ^ g[j];
        gray2bin = b;
    end
endfunction

// =======================
// Write domain logic
// =======================
always @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        wr_ptr_bin  <= 0;
        wr_ptr_gray <= 0;
        rd_ptr_gray_sync1 <= 0;
        rd_ptr_gray_sync2 <= 0;
    end else begin
        rd_ptr_gray_sync1 <= rd_ptr_gray;
        rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin + 1;
            wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
        end
    end
end

// =======================
// Read domain logic
// =======================
always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        rd_ptr_bin  <= 0;
        rd_ptr_gray <= 0;
        wr_ptr_gray_sync1 <= 0;
        wr_ptr_gray_sync2 <= 0;
        rd_data <= 0;
    end else begin
        wr_ptr_gray_sync1 <= wr_ptr_gray;
        wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin  <= rd_ptr_bin + 1;
            rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
        end
    end
end

// =======================
// Status logic
// =======================

// Empty when pointers equal
assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

// Full when next write pointer == read pointer (with MSB inverted)
wire [ADDR_WIDTH:0] wr_ptr_gray_next = bin2gray(wr_ptr_bin + 1);
assign full = (wr_ptr_gray_next == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
                                    rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

// Count (approx, for debug/monitoring)
assign wr_count = wr_ptr_bin - gray2bin(rd_ptr_gray_sync2);
assign rd_count = gray2bin(wr_ptr_gray_sync2) - rd_ptr_bin;

endmodule

