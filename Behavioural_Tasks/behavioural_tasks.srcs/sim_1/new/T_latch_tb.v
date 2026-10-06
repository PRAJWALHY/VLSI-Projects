`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 15:21:24
// Design Name: 
// Module Name: T_latch_tb
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


module T_latch_tb();

   reg enb,rst,t_in;
   wire q , qbar;
   
   T_latch dut(enb,rst,t_in,q,qbar);
   
    // with out task
    initial
         begin
         {enb,rst,t_in} = 0;
    end  
    
     always #5 enb =~enb;  
           
     initial 
     begin
     rst = 1; 
     #10;
     rst = 0; 
     #10;
     t_in = 1;
      #10;
     t_in = 0;
      
     end  
     
endmodule
    
    
    
    
    /*task test;
input enb_in;
input rst_in;
input t_in_in;
begin
    enb = enb_in;
    rst = rst_in;
    t_in = t_in_in;
    #10;
    end
    endtask
    initial 
    begin
    
    
    test(0,0,0);   // Enable = 0
    test(1,1,0);   // Reset
    test(1,0,0);   // Hold
    test(1,0,1);   // Toggle
    test(1,0,1);   // Toggle again                   //
    test(1,0,0);   // Hold
    test(0,0,1);   // Enable = 0
    test(1,1,1);   // Reset

    #10;
    $finish;
end  */





/*`timescale 1ns/1ps

module T_latch_tb;

reg enb;
reg rst;
reg t_in;

wire q;
wire qbar;

T_latch uut(
    .enb(enb),
    .rst(rst),
    .t_in(t_in),
    .q(q),
    .qbar(qbar)
);

task test;
input enb_in;
input rst_in;
input t_in_in;

begin
    enb = enb_in;
    rst = rst_in;
    t_in = t_in_in;
    #10;
end
endtask

initial
begin
    // Initialize
    enb = 0;
    rst = 0;
    t_in = 0;
    #10;

    test(1,1,0);   // Reset
    test(1,0,0);   // Hold
    test(1,0,1);   // Toggle
    test(1,0,1);   // Toggle again
    test(1,0,0);   // Hold
    test(0,0,1);   // Enable = 0 (No change)
    test(1,0,1);   // Toggle
    test(1,1,1);   // Reset

    #10;
    $finish;
end

endmodule   */