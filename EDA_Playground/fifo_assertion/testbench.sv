// imidiate asserstion

// module ex;
//   int a;
//   int b;
  
//   initial begin
//     assert(a==b)
//       $display("pass:a and b are equal");
//     else
//       $error("fail:a and b are not equal");
//   end
// endmodule



// // deffered immidiate asserstion

// module tb;
//   reg a,b;
//   assign b=!a;
  
//   always_comb begin//these both are running in the active region so its getting error 
//     assert#0 (b!=a) // adding #0 is deffered now this line is excuting in inactive region
//       $display("pass t=%t",$time);
//     else
//       $display("fail t=%t",$time);
//   end
//   initial begin
//     a=1;
//     #10;
//     a=0;
//     #20;
//     $finish;
//   end
// endmodule

//concurrent asserstion using fifo

module tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 4;
    logic clk;
    logic rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic                  full;
    logic                  empty;

  initial begin
        $dumpfile("fifo_waveform.vcd");
        $dumpvars(0, tb);
    end
  
 // DUT
    
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .wdata (wdata),
        .rdata (rdata),
        .full  (full),
        .empty (empty)
    );
    // Clock
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end
    // ASSERTION 1
    // Cannot write when fifo is full

    property p_no_write_when_full;

        @(posedge clk)
        disable iff (!rst_n)

        full |-> !wr_en;

    endproperty

    assert property (p_no_write_when_full)

        else $error("ASSERTION FAILED: Write attempted when FIFO is FULL");


    // ASSERTION 2
    // Cannot read when fifo is empty
    property p_no_read_when_empty;

        @(posedge clk)
        disable iff (!rst_n)

        empty |-> !rd_en;

    endproperty

    assert property (p_no_read_when_empty)

        else $error("ASSERTION FAILED: Read attempted when FIFO is EMPTY");


    // ASSERTION 3
  //fifo empty=1 and wr_enb=1 fifo should be written after 1 cycle fifo empty should be 0

    property p_write_clears_empty;

        @(posedge clk)
      disable iff (!rst_n)   //iff is used to disable the assertion during reset  empty should be 1 count and full should be 0

        (empty && wr_en && !full)
        |-> ##1 !empty;

    endproperty

    assert property (p_write_clears_empty)

        else $error("ASSERTION FAILED: EMPTY did not clear after write");

    // ASSERTION 4
    // Read from full fifo
    // full should become 0 next cycle

    property p_read_clears_full;

        @(posedge clk)
        disable iff (!rst_n)

        (full && rd_en && !empty)
        |-> ##1 !full;

    endproperty

    assert property (p_read_clears_full)

        else $error("ASSERTION FAILED: FULL did not clear after read");

    // ASSERTION 5
    // Count should increase after write

    property p_count_increase;

        @(posedge clk)
        disable iff (!rst_n)

        (wr_en && !rd_en && !full)
      |-> ##1 (dut.count == $past(dut.count) + 1);//checking the past o/p and incrimenting

    endproperty

    assert property (p_count_increase)

        else $error("ASSERTION FAILED: FIFO count did not increase");


    // ASSERTION 6
    // Count should decrease after READ

    property p_count_decrease;

        @(posedge clk)
        disable iff (!rst_n)

        (!wr_en && rd_en && !empty)
      |-> ##1 (dut.count == $past(dut.count) - 1);//decrimenting the count of the fifo

    endproperty

    assert property (p_count_decrease)

        else $error("ASSERTION FAILED: FIFO count did not decrease");


    // ASSERTION 7
    // EMPTY must correspond to count == 0

    property p_empty_check;

        @(posedge clk)
        disable iff (!rst_n)

        empty |-> (dut.count == 0);

    endproperty

    assert property (p_empty_check)

        else $error("ASSERTION FAILED: EMPTY != COUNT==0");


    // ASSERTION 8
    // FULL must correspond to count == DEPTH

    property p_full_check;

        @(posedge clk)
        disable iff (!rst_n)

        full |-> (dut.count == DEPTH);

    endproperty

    assert property (p_full_check)

        else $error("ASSERTION FAILED: FULL != COUNT==DEPTH");


    // displayinfg the fifo statements

    always @(posedge clk) begin

        if (rst_n) begin

            $display(
                "TIME=%0t | WR=%0b RD=%0b WDATA=%0h RDATA=%0h COUNT=%0d FULL=%0b EMPTY=%0b",
                $time,
                wr_en,
                rd_en,
                wdata,
                rdata,
                dut.count,
                full,
                empty
            );

        end

    end


    // TEST

    initial begin

        // Initial values
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wdata = 0;

        // Reset
        #12;

        rst_n = 1;

        // WRITE 1

        @(negedge clk);

        wr_en = 1;
        wdata = 8'hAA;

        @(negedge clk);

        wr_en = 1;
        wdata = 8'hBB;

        @(negedge clk);

        wr_en = 1;
        wdata = 8'hCC;

        @(negedge clk);

        wr_en = 1;
        wdata = 8'hDD;

        // FIFO should now be FULL

        @(negedge clk);

        wr_en = 0;

        // READ

        @(negedge clk);

        rd_en = 1;

        @(negedge clk);

        rd_en = 1;

        @(negedge clk);

        rd_en = 1;

        @(negedge clk);

        rd_en = 1;

        @(negedge clk);

        rd_en = 0;

        // END

        #20;

      $display("Simulation finished");


        $finish;

    end

endmodule

