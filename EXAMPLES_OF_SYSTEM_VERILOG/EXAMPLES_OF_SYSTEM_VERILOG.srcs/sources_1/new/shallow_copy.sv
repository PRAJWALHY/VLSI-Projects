`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2026 16:50:28
// Design Name: 
// Module Name: shallow_copy
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


module shallow_copy();
 class header;
  int id;
  function new(int id_1);
    this.id=id_1;
  endfunction
  
  function void display();
    $display("id = %d",id);
  endfunction
  endclass
 
  class packet;
    int addr;
    int data;
    
    header h_hdl;
    function new(int addr,int data,int id);
      this.addr =addr;
      this.data = data;
      
    endfunction
    function display(string name);
      $display("[%s] addr = %d data = %d",name ,addr,data);
  endfunction
    endclass
    
endmodule
