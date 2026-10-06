`timescale 1ns/1ps

module dual_clk_dual_port_tb;

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

// DUT
dual_clk_dual_port DUT
(
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


initial
    clk_a = 0;

always #5 clk_a = ~clk_a;


initial
    clk_b = 0;

always #7 clk_b = ~clk_b;

// Expected Memory


reg [7:0] exp_mem [0:7];

integer i;



// Write using Port A


task write_portA;

input [2:0] address;
input [7:0] data;

begin

@(posedge clk_a);

en_a   = 1;
wr_a   = 1;
rd_a   = 0;

addr_a = address;
din_a  = data;

exp_mem[address] = data;

@(posedge clk_a);

en_a = 0;
wr_a = 0;

end

endtask


// Read using Port B

task read_portB;

input [2:0] address;

begin

@(posedge clk_b);

en_b   = 1;
wr_b   = 0;
rd_b   = 1;

addr_b = address;

@(posedge clk_b);

check_portB(address);

en_b = 0;
rd_b = 0;

end

endtask



// Write using Port B

task write_portB;

input [2:0] address;
input [7:0] data;

begin

@(posedge clk_b);

en_b   = 1;
wr_b   = 1;
rd_b   = 0;

addr_b = address;
din_b  = data;

exp_mem[address] = data;

@(posedge clk_b);

en_b = 0;
wr_b = 0;

end

endtask


// Read using Port A


task read_portA;

input [2:0] address;

begin

@(posedge clk_a);

en_a   = 1;
wr_a   = 0;
rd_a   = 1;

addr_a = address;

@(posedge clk_a);

check_portA(address);

en_a = 0;
rd_a = 0;

end

endtask

// Checker Port A

task check_portA;

input [2:0] address;

begin

if(dout_a == exp_mem[address])

    $display("PASS PortA Addr=%0d Expected=%0h Got=%0h ",
             address,exp_mem[address],dout_a);

else

    $display("FAIL PortA Addr=%0d Expected=%0h Got=%0h",
             address,exp_mem[address],dout_a);

end

endtask



// Checker Port B


task check_portB;

input [2:0] address;

begin

if(dout_b == exp_mem[address])

    $display("PASS PortB Addr=%0d Expected=%0h Got=%0h",
             address,exp_mem[address],dout_b);

else

    $display("FAIL PortB Addr=%0d Expected=%0h Got=%0h",
             address,exp_mem[address],dout_b);

end

endtask


initial
begin

// Initialize

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

for(i=0;i<8;i=i+1)
    exp_mem[i]=0;

#20;

// Write Port A -> Read Port B

$display("WRITE PORT A -> READ PORT B");


for(i=0;i<10;i=i+1)
    write_portA(i,i+8'h10);

for(i=0;i<10;i=i+1)
    read_portB(i);

// Write Port B -> Read Port A
$display("WRITE PORT B -> READ PORT A");

for(i=0;i<10;i=i+1)
    write_portB(i,i+8'h80);

for(i=0;i<10;i=i+1)
    read_portA(i);


#50;
$finish;

end

endmodule