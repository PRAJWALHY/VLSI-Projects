
// INTERFACE


interface ram_if(input logic clk);

  logic rst_n;
  logic w_enb;
  logic r_enb;
  logic [6:0] addr;
  logic [7:0] wdata;
  logic [7:0] rdata;
  logic valid;

endinterface



// TRANSACTION


class transaction;

  typedef enum {WRITE, READ} op_t;

  rand op_t op;
  rand logic [6:0] addr;
  rand logic [7:0] wdata;

  logic [7:0] rdata;
  logic valid;

  function new();

    op    = WRITE;
    addr  = 7'h00;
    wdata = 8'h00;
    rdata = 8'h00;
    valid = 1'b0;

  endfunction


  function void print(string tag = "");

    $display("%0t : %s | op=%s addr=%0h wdata=%0h rdata=%0h valid=%b",
             $time,
             tag,
             op.name(),
             addr,
             wdata,
             rdata,
             valid);

  endfunction

endclass



// GENERATOR


class ram_generator;

  mailbox #(transaction) wr_mbox;
  mailbox #(transaction) rd_mbox;
  mailbox #(bit) wr_done_mbox;
  mailbox #(bit) rd_done_mbox;

  int unsigned num_writes;
  int unsigned num_reads;


function new(
  mailbox #(transaction) wr_mbox,
  mailbox #(transaction) rd_mbox,
  mailbox #(bit) wr_done_mbox,
  mailbox #(bit) rd_done_mbox,
  int unsigned num_writes = 16,
  int unsigned num_reads  = 16
);

  this.wr_mbox      = wr_mbox;
  this.rd_mbox      = rd_mbox;
  this.wr_done_mbox = wr_done_mbox;
  this.rd_done_mbox = rd_done_mbox;

  this.num_writes = num_writes;
  this.num_reads  = num_reads;

endfunction


// //  task run();

//     transaction txn;
//     logic [6:0] written_addr[];

//     written_addr = new[num_writes];


    
//     // WRITE PHASE
    
//     $display(" WRITE PHASE ");

//     for (int i = 0; i < num_writes; i++) begin

//       txn = new();

//       if (!txn.randomize() with {
//         op == transaction::WRITE;
//       }) begin

//         $display("ERROR: Write randomization failed");

//       end

//       written_addr[i] = txn.addr;

//       $display("%0t : GENERATOR WRITE : addr=%0h data=%0h",
//                $time,
//                txn.addr,
//                txn.wdata);

//       wr_mbox.put(txn);

//     end


    
//     // WAIT FOR ALL WRITES
    

//     begin

//       bit tok;

//       for (int i = 0; i < num_writes; i++) begin
//         wr_done_mbox.get(tok);
//       end

//     end


    
//     // READ PREVIOUSLY WRITTEN ADDRESSES
    
//     $display(" READ WRITTEN ADDRESSES ");

//     for (int i = 0; i < num_writes; i++) begin

//       txn = new();

//       txn.op   = transaction::READ;
//       txn.addr = written_addr[i];

//       $display("%0t : GENERATOR READ : addr=%0h",
//                $time,
//                txn.addr);

//       rd_mbox.put(txn);

//     end


    
//     // RANDOM READ PHASE
    

//     $display("");
//     $display(" RANDOM READ PHASE ");

//     for (int i = 0; i < num_reads; i++) begin

//       txn = new();

//       if (!txn.randomize() with {
//         op == transaction::READ;
//       }) begin

//         $display("ERROR: Read randomization failed");

//       end

//       $display("%0t : GENERATOR RANDOM READ : addr=%0h",
//                $time,
//                txn.addr);

//       rd_mbox.put(txn);

//     end

//   endtask
  
  
    
  
  // TC1 : PARALLEL READ AND WRITE

  task tc1_parallel_read_write();

    transaction wr_txn;
    transaction rd_txn;

    bit done;

    logic [6:0] written_addr [0:4];


    $display(" TC1 : PARALLEL READ AND WRITE");


    // First 5 writes
    for (int i = 0; i < 5; i++) begin

      wr_txn = new();

      if (!wr_txn.randomize() with {
        op == transaction::WRITE;
      }) begin
        $error("Write randomization failed");
      end

      written_addr[i] = wr_txn.addr;

      wr_mbox.put(wr_txn);

      $display("%0t : TC1 WRITE %0d : ADDR=%0h DATA=%0h",
               $time,
               i+1,
               wr_txn.addr,
               wr_txn.wdata);

    end


    // Wait for first 5 writes
    repeat(5)
      wr_done_mbox.get(done);


    $display("%0t : FIRST 5 WRITES COMPLETED", $time);


    // READ + WRITE SEQUENCE

    for (int i = 0; i < 5; i++) begin


      // READ previously written address

      rd_txn = new();

      rd_txn.op   = transaction::READ;
      rd_txn.addr = written_addr[i];

      rd_mbox.put(rd_txn);

      $display("%0t : TC1 READ SENT : ADDR=%0h",
               $time,
               rd_txn.addr);


      // Wait until READ driver completes

      rd_done_mbox.get(done);

      $display("%0t : TC1 READ COMPLETED",
               $time);


      // WRITE next transaction

      wr_txn = new();

      if (!wr_txn.randomize() with {
        op == transaction::WRITE;
      }) begin
        $error("Write randomization failed");
      end

      wr_mbox.put(wr_txn);

      $display("%0t : TC1 WRITE SENT : ADDR=%0h DATA=%0h",
               $time,
               wr_txn.addr,
               wr_txn.wdata);


      // Wait until WRITE driver completes

      wr_done_mbox.get(done);

      $display("%0t : TC1 WRITE COMPLETED",
               $time);

    end

  endtask


  // TC2 : READ UNWRITTEN ADDRESS


  task tc2_unwritten_read();

    transaction txn;
    bit done;



    $display(" TC2 : READ UNWRITTEN ADDRESS");



    // Write address 10
    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h10;
    txn.wdata = 8'hAA;

    wr_mbox.put(txn);


    // Write address 20
    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h20;
    txn.wdata = 8'h55;

    wr_mbox.put(txn);


    // Wait for writes
    repeat(2)
      wr_done_mbox.get(done);


    // Read written address
    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h10;

    rd_mbox.put(txn);

    rd_done_mbox.get(done);


    // Read NEVER written address
    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h50;

    rd_mbox.put(txn);

    rd_done_mbox.get(done);


    $display("TC2 : UNWRITTEN ADDRESS 7'h50 SENT");

  endtask


  
  // TC3 : MULTIPLE WRITES AND READS
  

  task tc3_multiple_write_read();

    transaction wr_txn;
    transaction rd_txn;

    bit done;

    logic [6:0] written_addr [0:9];
    

    $display(" TC3 : MULTIPLE WRITES AND READS");


    // 10 WRITES
    for (int i = 0; i < 10; i++) begin

      wr_txn = new();

      if (!wr_txn.randomize() with {
        op == transaction::WRITE;
      }) begin
        $error("Write randomization failed");
      end

      written_addr[i] = wr_txn.addr;

      wr_mbox.put(wr_txn);

      $display("%0t : TC3 WRITE %0d : ADDR=%0h DATA=%0h",
               $time,
               i+1,
               wr_txn.addr,
               wr_txn.wdata);

    end


    // Wait for all writes
    repeat(10)
      wr_done_mbox.get(done);


    $display("TC3 : ALL 10 WRITES COMPLETED");


    // Read same 10 addresses
    for (int i = 0; i < 10; i++) begin

      rd_txn = new();

      rd_txn.op   = transaction::READ;
      rd_txn.addr = written_addr[i];

      rd_mbox.put(rd_txn);

      $display("%0t : TC3 READ %0d : ADDR=%0h",
               $time,
               i+1,
               rd_txn.addr);

      rd_done_mbox.get(done);

    end


    $display("TC3 : ALL 10 READS COMPLETED");

  endtask
  
endclass




/////////DRIVERR

// WRITE DRIVER


class ram_wr_driver;

  virtual ram_if vif;

  mailbox #(transaction) wr_mbox;
  mailbox #(bit) wr_done_mbox;

  int unsigned txn_count;


  function new(
    virtual ram_if vif,
    mailbox #(transaction) wr_mbox,
    mailbox #(bit) wr_done_mbox
  );

    this.vif          = vif;
    this.wr_mbox      = wr_mbox;
    this.wr_done_mbox = wr_done_mbox;

    txn_count = 0;

  endfunction


  task reset(int cycles = 4);

    $display("%0t : Applying reset", $time);

    vif.rst_n = 1'b0;
    vif.w_enb = 1'b0;
    vif.r_enb = 1'b0;
    vif.addr  = 7'h00;
    vif.wdata = 8'h00;

    repeat(cycles)
      @(posedge vif.clk);

    vif.rst_n = 1'b1;

    $display("%0t : Reset deasserted", $time);

  endtask


  task drive(transaction txn);

    @(negedge vif.clk);

    vif.w_enb = 1'b1;
    vif.r_enb = 1'b0;
    vif.addr  = txn.addr;
    vif.wdata = txn.wdata;

    $display("%0t : WRITE DRIVER : addr=%0h data=%0h",
             $time,
             txn.addr,
             txn.wdata);

    @(posedge vif.clk);

    // Allow DUT to complete write
    @(negedge vif.clk);

    vif.w_enb = 1'b0;
    vif.addr  = 7'h00;
    vif.wdata = 8'h00;

  endtask


  task run();

    transaction txn;

    forever begin

      wr_mbox.get(txn);

      drive(txn);

      txn_count++;

      wr_done_mbox.put(1'b1);

    end

  endtask

endclass



// READ DRIVER


class ram_read_driver;

  virtual ram_if vif;

  mailbox #(transaction) rd_mbox;
  mailbox #(bit) rd_done_mbox;

  int unsigned txn_count;

function new(
  virtual ram_if vif,
  mailbox #(transaction) rd_mbox,
  mailbox #(bit) rd_done_mbox
);

  this.vif         = vif;
  this.rd_mbox     = rd_mbox;
  this.rd_done_mbox = rd_done_mbox;

  txn_count = 0;

endfunction


  task drive(transaction txn);

    
    // Put address before rising edge
    

    @(negedge vif.clk);

    vif.r_enb = 1'b1;
    vif.w_enb = 1'b0;
    vif.addr  = txn.addr;

    $display("%0t : READ DRIVER : addr=%0h",
             $time,
             txn.addr);


    
    // RAM samples request
    

    @(posedge vif.clk);


    
    // Keep request stable until after response

    @(negedge vif.clk);

    vif.r_enb = 1'b0;
    vif.addr  = 7'h00;

    txn_count++;

  endtask


  task run();

    transaction txn;

    forever begin

      rd_mbox.get(txn);

      drive(txn);
      
      // Tell testcase that READ is completed
       rd_done_mbox.put(1'b1);
    end

  endtask

endclass



// MONITOR


class ram_monitor;

  virtual ram_if vif;

  mailbox #(transaction) mon_mbox;


  function new(
    virtual ram_if vif,
    mailbox #(transaction) mon_mbox
  );

    this.vif      = vif;
    this.mon_mbox = mon_mbox;

  endfunction


  task run();

    transaction txn;
    logic [6:0] read_addr;


    forever begin

      @(posedge vif.clk);


      
      // WRITE MONITOR
      

      if (vif.w_enb && vif.rst_n) begin

        txn = new();

        txn.op    = transaction::WRITE;
        txn.addr  = vif.addr;
        txn.wdata = vif.wdata;
        txn.valid = vif.valid;

        $display("%0t : MONITOR WRITE : addr=%0h data=%0h",
                 $time,
                 txn.addr,
                 txn.wdata);

        mon_mbox.put(txn);

      end


      
      // READ MONITOR
      

      if (vif.r_enb && vif.rst_n) begin

        // Save address BEFORE it changes
        read_addr = vif.addr;

        // Wait for nonblocking assignment to update rdata
        #1;

        txn = new();

        txn.op    = transaction::READ;
        txn.addr  = read_addr;
        txn.rdata = vif.rdata;
        txn.valid = vif.valid;

        $display("%0t : MONITOR READ : addr=%0h data=%0h valid=%b",
                 $time,
                 txn.addr,
                 txn.rdata,
                 txn.valid);

        mon_mbox.put(txn);

      end

    end

  endtask

endclass



// SCOREBOARD

class ram_scoreboard;

  mailbox #(transaction) mon_mbox;

  // Associative memory
  logic [7:0] expected_mem [logic [6:0]];// data --> address creating 

  int write_count;
  int read_count;
  int pass_count;
  int fail_count;
  int warning_count;


  function new(mailbox #(transaction) mon_mbox);

    this.mon_mbox = mon_mbox;

    write_count   = 0;
    read_count    = 0;
    pass_count    = 0;
    fail_count    = 0;
    warning_count = 0;

  endfunction


  task run();

    transaction txn;

    forever begin

      mon_mbox.get(txn);



      // WRITE

      if (txn.op == transaction::WRITE) begin

        expected_mem[txn.addr] = txn.wdata;

        write_count++;

        $display("%0t : SCOREBOARD WRITE : addr=%0h data=%0h",
                 $time,
                 txn.addr,
                 txn.wdata);

      end

    // READ

      else if (txn.op == transaction::READ) begin

        read_count++;

        // Check whether address exists
        if (expected_mem.exists(txn.addr)) begin

          // Address was written before

          if (expected_mem[txn.addr] == txn.rdata) begin

            $display("%0t : SCOREBOARD PASS : addr=%0h Expected=%0h Actual=%0h",
                     $time,
                     txn.addr,
                     expected_mem[txn.addr],
                     txn.rdata);

            pass_count++;

          end

          else begin

            $display("%0t : SCOREBOARD FAIL : addr=%0h Expected=%0h Actual=%0h",
                     $time,
                     txn.addr,
                     expected_mem[txn.addr],
                     txn.rdata);

            fail_count++;

          end

        end

        else begin

          // Address was never written

          $display("%0t : SCOREBOARD WARNING : addr=%0h was NEVER WRITTEN. Actual=%0h",
                   $time,
                   txn.addr,
                   txn.rdata);

          warning_count++;

        end

      end

    end

  endtask


  function void report();

    $display("RAM SCOREBOARD REPORT");

    $display("WRITE COUNT   = %0d", write_count);
    $display("READ COUNT    = %0d", read_count);
    $display("PASS COUNT    = %0d", pass_count);
    $display("FAIL COUNT    = %0d", fail_count);
    $display("WARNING COUNT = %0d", warning_count);

    if (fail_count == 0)
      $display("******** TEST PASSED ********");
    else
      $display("******** TEST FAILED ********");

  endfunction

endclass


// ENVIRONMENT


class ram_environment;

  virtual ram_if vif;


  mailbox #(transaction) wr_mbox;
  mailbox #(transaction) rd_mbox;
  mailbox #(transaction) mon_mbox;

  mailbox #(bit) wr_done_mbox;
  mailbox #(bit) rd_done_mbox;// read driver mailbox


  ram_generator   gen;
  ram_wr_driver   wr_drv;
  ram_read_driver rd_drv;
  ram_monitor     mon;
  ram_scoreboard  scb;


  function new(virtual ram_if vif);

    this.vif = vif;


    
    // Mailboxes
    

    wr_mbox      = new();
    rd_mbox      = new();
    mon_mbox     = new();
    wr_done_mbox = new();
    rd_done_mbox = new();


    
    // Components
    

    gen = new(
      wr_mbox,
      rd_mbox,
      wr_done_mbox,
       rd_done_mbox,
      10,
      10
    );


    wr_drv = new(
      vif,
      wr_mbox,
      wr_done_mbox
    );


    rd_drv = new(
      vif,
      rd_mbox,
       rd_done_mbox
    );


    mon = new(
      vif,
      mon_mbox
    );


    scb = new(
      mon_mbox
    );

  endfunction

task run();

  $display("RAM ENVIRONMENT START");

  // Reset DUT
  wr_drv.reset();

  // Start verification components
  fork
    wr_drv.run();
    rd_drv.run();
    mon.run();
    scb.run();
  join_none

  $display("RAM ENVIRONMENT READY");

endtask


    
    // Start generator
    

  //  gen.run();


  //  $display("GENERATOR COMPLETED");

  //endtask

endclass




// TOP TESTBENCH


module tb;

  logic clk;

  ram_if vif(clk);


  
  // DUT
  

  decoder_ram dut (

    .clk   (clk),
    .rst_n (vif.rst_n),
    .w_enb (vif.w_enb),
    .r_enb (vif.r_enb),
    .addr  (vif.addr),
    .wdata (vif.wdata),
    .rdata (vif.rdata),
    .valid (vif.valid)

  );


  
  // ENVIRONMENT and TEST CASE
  

  ram_environment env;



  
  // CLOCK
  

  initial begin

    clk = 1'b0;

    forever
      #5 clk = ~clk;

  end


  
  // TEST
  
initial begin

  $display("");
  $display("RAM TEST STARTED");
// Create environment
env = new(vif);

// Start environment
env.run();

// Run TC1
 env.gen.tc1_parallel_read_write();  //PARALLEL READ AND WRITE

// Run TC2
 env.gen.tc2_unwritten_read();  //WARNING 

// Run TC3

env.gen.tc3_multiple_write_read(); // wait for all 10 writes--->READ same 10 addresses

  #1000;

  // Scoreboard report
  env.scb.report();

  $display("");
  $display(" RAM TEST FINISHED");

  $finish;

end
endmodule





