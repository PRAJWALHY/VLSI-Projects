`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 17:38:53
// Design Name: 
// Module Name: full_adder_tb
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


module full_adder_tb();

reg a_tb,b_tb,cin_tb;
wire sum_tb,carry_tb;

    FULL_ADDER dut(a_tb,b_tb,cin_tb,sum_tb,carry_tb);
    
 /*   initial {
    #10 clk=~clk}
    
    always
    #10 clk=~clk;*/
    task dr_tb;
    input a ,b,cin;
    begin
        a_tb = a;
        b_tb = b;
        cin_tb = cin;
        #100;
        end
      endtask
        
    initial 
        begin 
        {a_tb,b_tb,cin_tb}=0;
        end 
        
    initial 
        begin 
          $monitor("the value of a_tb is %b and b_tb is %b, cin_tb is %b ,sum_tb is %b, carry_tb is %b",a_tb,b_tb,cin_tb,sum_tb,carry_tb);
       /* a_tb=0; b_tb=0; cin_tb=0; #100;
        a_tb=0; b_tb=0; cin_tb=1; #100;
        a_tb=0; b_tb=1; cin_tb=0; #100;
        a_tb=0; b_tb=1; cin_tb=1; #100;
        a_tb=1; b_tb=0; cin_tb=0; #100;
        a_tb=1; b_tb=0; cin_tb=1; #100;
        a_tb=1; b_tb=1; cin_tb=0; #100;
        a_tb=1; b_tb=1; cin_tb=1; #100; */
      
      dr_tb(0,0,0);
      dr_tb(0,0,1);
      dr_tb(0,1,0);
      dr_tb(0,1,1);
      dr_tb(1,0,0);
      dr_tb(1,0,1);
      dr_tb(1,1,0);
      dr_tb(1,1,1);
      
      dr_tb(1,1,0);
        
        end
endmodule
