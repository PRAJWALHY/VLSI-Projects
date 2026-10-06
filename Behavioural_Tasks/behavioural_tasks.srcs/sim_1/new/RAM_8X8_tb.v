`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.07.2026 15:01:27
// Design Name: 
// Module Name: RAM_8X8_tb
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


/*module RAM_8X8_tb();

reg clk,rst,wr_enb;
reg [2:0] wr_addr;
reg [7:0] data_in;
reg [2:0] rd_addr;

wire [7:0] data_out;

RAM_8X8 dut(clk,rst,wr_enb,wr_addr,data_in,rd_addr,data_out);
    initial 
        begin 
        {clk,rst,wr_enb,wr_addr,data_in,rd_addr}=0;
        
        end
        always #5 clk = ~ clk;
        initial 
         begin 
         rst=1;
         #10;
         rst=0;
         #10;
         wr_enb=1;
         wr_addr=3'b100;
         data_in =5;
         #10;
         
         wr_addr=3'b101;
         data_in= 10;
         #10;
         
         wr_enb=0;
         rd_addr=3'b100;
         #10;
         rd_addr=3'b101;
         

         $finish;
    end
endmodule */
`timescale 1ns/1ps

module RAM_8X8_tb();

reg clk;
reg wr_enb;
reg rd_enb;
reg [2:0] addr;
reg [7:0] data_in;
wire [7:0] data_out;

RAM_8X8 dut(
    .clk(clk),
    .wr_enb(wr_enb),
    .rd_enb(rd_enb),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out)
);

// Clock Generation
always #5 clk = ~clk;

initial
begin
    clk = 0;
    wr_enb = 0;
    rd_enb = 0;
    addr = 0;
    data_in = 0;

    // Write 12 into address 0
    #10;
    wr_enb = 1;
    addr = 3'b000;
    data_in = 8'd12;

    // Write 25 into address 1
    #10;
    addr = 3'b001;
    data_in = 8'd25;

    // Stop Writing
    #10;
    wr_enb = 0;

    // Read Address 0
    #10;
    rd_enb = 1;
    addr = 3'b000;

    // Read Address 1
    #10;
    addr = 3'b001;

    // Disable Read
    #10;
    rd_enb = 0;

    #20;
    $finish;
end

endmodule
