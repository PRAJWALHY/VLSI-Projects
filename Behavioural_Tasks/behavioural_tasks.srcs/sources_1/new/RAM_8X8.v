`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.07.2026 15:00:26
// Design Name: 
// Module Name: RAM_8X8
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


/*module RAM_8X8(
    input clk,rst,wr_enb,input[3:0] wr_addr,input [3:0]data_in,
    input [3:0]rd_addr,output reg [7:0] data_out  );
    
    //creating one internal memory 
    
        reg [7:0] mem[7:0];
        
        integer i;
        
        // write logic and read logic
        
        always @(posedge clk or rst)
            begin 
                if(rst)
                    for(i=0;i<7;i=i+1)
                     mem[i] <=0;
                else 
                     if (wr_enb ==1)
              //  begin
                    mem[wr_addr]<=data_in;
           //     end 
                else if (wr_enb ==0)
             //   begin
                    data_out <=mem[rd_addr];
            //    end
            end
endmodule */


module RAM_8X8(
    input clk,
    input wr_enb,
    input rd_enb,
    input [2:0] addr,
    input [7:0] data_in,
    output reg [7:0] data_out
);

reg [7:0] mem [0:7];

// Write Operation
always @(posedge clk)
begin
    if (wr_enb)
        mem[addr] <= data_in;
end

// Read Operation
always @(*)
begin
    if (rd_enb)
        data_out = mem[addr];
    else
        data_out = 8'b0;
end

endmodule
