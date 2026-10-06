`timescale 1ns/1ps

module dual_port_ram_tb();

reg clk_a;
reg clk_b;

reg en_a;
reg wr_a;
reg rd_a;
reg [2:0] addr_a;
reg [7:0] din_a;
wire [7:0] dout_a;

reg en_b;
reg wr_b;
reg rd_b;
reg [2:0] addr_b;
reg [7:0] din_b;
wire [7:0] dout_b;

dual_port_ram DUT(
    .clk_a(clk_a),
    .clk_b(clk_b),

    .en_a(en_a),
    .wr_a(wr_a),
    .rd_a(rd_a),
    .addr_a(addr_a),
    .din_a(din_a),
    .dout_a(dout_a),

    .en_b(en_b),
    .wr_b(wr_b),
    .rd_b(rd_b),
    .addr_b(addr_b),
    .din_b(din_b),
    .dout_b(dout_b)
);

// Clock A : 10 ns period
initial
begin
    clk_a = 0;
    forever #5 clk_a = ~clk_a;
end

// Clock B : 20 ns period
initial
begin
    clk_b = 0;
    forever #10 clk_b = ~clk_b;
end

initial
begin

    en_a=0;
    wr_a=0;
    rd_a=0;
    addr_a=0;
    din_a=0;

    en_b=0;
    wr_b=0;
    rd_b=0;
    addr_b=0;
    din_b=0;

    #20;

    
    // Port A Write
    $display("\n-------------- TEST CASE 1-----------");
    $display("Port A Write : Writing AA to Address 2");
    en_a=1;
    wr_a=1;
    rd_a=0;
    addr_a=3'd2;
    din_a=8'hAA;

    #20;

    
    // Port B Read
    $display("\n------------ TEST CASE 2 --------------");
    $display("Port B Read : Reading Address 2 (Expected = AA)");
    en_b=1;
    wr_b=0;
    rd_b=1;
    addr_b=3'd2;

    #40;
    $display("Data Read from Port B = %h",dout_b);

    
    // Port B Write
    $display("\n--------------- TEST CASE 3 -----------");
    $display("Port B Write : Writing 55 to Address 5");

    wr_b=1;
    rd_b=0;
    addr_b=3'd5;
    din_b=8'h55;

    #40;

    
    // Port A Read
    $display("\n------------ TEST CASE 4 -------------");
    $display("Port A Read : Reading Address 5 (Expected = 55)");
    wr_a=0;
    rd_a=1;
    addr_a=3'd5;

    #40;
     $display("Data Read from Port A = %h",dout_a);
    
    // Simultaneous Write
    $display("\n----------- TEST CASE 5 -------------");
    $display("Simultaneous Write :");
    $display("Port A -> Address 1 = 11");
    $display("Port B -> Address 6 = 66");
    
    wr_a=1;
    rd_a=0;
    addr_a=3'd1;
    din_a=8'h11;

    wr_b=1;
    rd_b=0;
    addr_b=3'd6;
    din_b=8'h66;

    #40;

    
    // Simultaneous Read
    $display("\n-------------- TEST CASE 6 ---------------");
    $display("Simultaneous Read : Address1 & Address6");
    wr_a=0;
    rd_a=1;
    addr_a=3'd1;

    wr_b=0;
    rd_b=1;
    addr_b=3'd6;

    #40;
    $display("Port A Data = %h",dout_a);
    $display("Port B Data = %h",dout_b);
    
    // Same Address Access
    $display("\n----------- TEST CASE 7----------------");
    $display("Port A Write and Port B Read at Address 4");
    wr_a=1;
    rd_a=0;
    addr_a=3'd4;
    din_a=8'hF0;

    wr_b=0;
    rd_b=1;
    addr_b=3'd4;

    #40;
    $display("Port B Data = %h",dout_b);
  
    // Write Collision
    $display("\n------------ TEST CASE 8 ---------------");
    $display("Collision: Both Ports Writing Address 7");
    $display("Port A = AA, Port B = 55");  
    wr_a=1;
    rd_a=0;
    addr_a=3'd7;
    din_a=8'hAA;

    wr_b=1;
    rd_b=0;
    addr_b=3'd7;
    din_b=8'h55;

    #40;

  
    // Read Back
    $display("Read Back Address 7");

    wr_a=0;
    rd_a=1;
    addr_a=3'd7;

    wr_b=0;
    rd_b=1;
    addr_b=3'd7;

    #40;
    $display("Port A Data = %h",dout_a);
    $display("Port B Data = %h",dout_b);

    $display("\n----------- SIMULATION COMPLETED SUCCESSFULLY -------------");  

    $finish;

end

endmodule