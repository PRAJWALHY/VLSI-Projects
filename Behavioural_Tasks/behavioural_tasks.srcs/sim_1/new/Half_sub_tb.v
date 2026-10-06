`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2026 11:15:14
// Design Name: 
// Module Name: Half_sub_tb
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


module Half_sub_tb;
        reg a_tb,b_tb;
        wire diff_tb,borrow_tb;
         
          
          Half_sub uut(a_tb,b_tb,diff_tb,borrow_tb);
          
         task test_case;
         input a,b;
         begin
             a_tb=a;
            b_tb=b;
         #10;
         
         $display("A=%b B=%b Diff=%b Borrow=%b",a_tb,b_tb,diff_tb,borrow_tb);
         end
      endtask
      initial begin 
                
                $display("Half sub testbench");
     
      test_case(0,0);
      test_case(0,1);
      test_case(1,0);
      test_case(1,1);
      $finish;
  end
      
endmodule

