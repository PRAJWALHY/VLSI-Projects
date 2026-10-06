`timescale 1ns/1ps

module Full_sub_using_half_sub_tb;

reg a;
reg b;
reg bin;

wire diff;
wire borrow;

// Instantiate the Full Subtractor
Full_sub_using_half_sub uut(
    .a(a),
    .b(b),
    .bin(bin),
    .diff(diff),
    .borrow(borrow)
);

task test;
input A;
input B;
input Bin;

begin
    a = A;
    b = B;
    bin = Bin;
    #10;
    $display("a=%b b=%b bin=%b --> diff=%b borrow=%b",
             a,b,bin,diff,borrow);
end
endtask

initial
begin
  //  $display("--------------------------------------");
    $display("a b bin | diff borrow");
  //  $display("--------------------------------------");

    test(0,0,0);
    test(0,0,1);
    test(0,1,0);
    test(0,1,1);
    test(1,0,0);
    test(1,0,1);
    test(1,1,0);
    test(1,1,1);

    #10;
    $finish;
end

endmodule