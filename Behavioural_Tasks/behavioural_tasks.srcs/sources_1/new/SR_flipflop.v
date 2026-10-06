`timescale 1ns / 1ps
module SR_flipflop (input clk,rst,s,r,output reg q ,qbar);
    always @(posedge clk)
    begin
    
        if (rst)
        begin
            q <= 1'b0;
            qbar <= 1'b1;
            end  
        
     /*  else if (s == 0 && r == 0) begin
        q <= q;
        qbar <= qbar; 
        end  */
           else if(s ==0 && r ==0)    // hold
           begin
            q    <= q;
            qbar <= qbar;
           end 
           
           else if(s==0 && r==1)   // reset
           begin
            q    <= 1'b0;
            qbar <= 1'b1;
           end 
          
          else if(s==1 && r ==0)  // set 
           begin
            q    <= 1'b1;
            qbar <= 1'b0;
           end 
    
           else if(s==1 && r ==1)    // invalid
           begin
            q    <= 1'bx;
            qbar <= 1'bx;
           end 
    end
endmodule             












/*module SR_flipflop(
    input clk,
    input rst,
    input s,
    input r,
    output reg q,
    output reg qbar
);

always @(posedge clk)
begin
    if(rst)
    begin
        q    <= 1'b0;
        qbar <= 1'b1;
    end

    // Hold
    else if(s==0 && r==0)
    begin
        q    <= q;
        qbar <= qbar;
    end

    // Reset
    else if(s==0 && r==1)
    begin
        q    <= 1'b0;
        qbar <= 1'b1;
    end

    // Set
    else if(s==1 && r==0)
    begin
        q    <= 1'b1;
        qbar <= 1'b0;
    end

    // Invalid
    else if(s==1 && r==1)
    begin
        q    <= 1'bx;
        qbar <= 1'bx;
    end
end

endmodule  */
