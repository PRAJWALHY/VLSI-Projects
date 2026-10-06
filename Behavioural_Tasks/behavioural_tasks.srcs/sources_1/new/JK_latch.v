`timescale 1ns / 1ps

module JK_latch(
input enb,rst,j,k,output reg  q,qbar
    );
    always @(enb,rst)begin
    
    if (rst) begin
         q <= 1'b0;
         qbar <= 1'b1;
    end
    
    if (enb)
        begin
       
        if(j == 0 && k ==0)         // hold state 
        begin 
            q <= q;
            qbar <= qbar;
            end
            
         else if (j== 0 && k == 1)    // reset state
         begin 
            q <= 1'b0;
            qbar <= 1'b1;
            end
            
            else if (j == 1 && k == 0)               // set state
                begin
                q <= 1'b1;
                qbar <= 1'b0;
                end
                
                else if (j == 1 && k == 1)    // toggle state 
                begin
                q <= ~q;
                qbar <= ~qbar;    
         end
         end 
         end
endmodule


