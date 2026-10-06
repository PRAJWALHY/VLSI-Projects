
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

  virtual ram_if vif;

  int unsigned num_writes;
  int unsigned num_reads;    


  mailbox #(transaction) wr_mbox;
  mailbox #(transaction) rd_mbox;
  mailbox #(bit) wr_done_mbox;
  mailbox #(bit) rd_done_mbox;


function new(
  virtual ram_if vif,
  mailbox #(transaction) wr_mbox,
  mailbox #(transaction) rd_mbox,
  mailbox #(bit) wr_done_mbox,
  mailbox #(bit) rd_done_mbox,
  int unsigned num_writes = 16,
  int unsigned num_reads  = 16
);

  this.vif          = vif;
  this.wr_mbox      = wr_mbox;
  this.rd_mbox      = rd_mbox;
  this.wr_done_mbox = wr_done_mbox;
  this.rd_done_mbox = rd_done_mbox;

  this.num_writes = num_writes;
  this.num_reads  = num_reads;

endfunction

    
  
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

// WRITE + READ DRIVER


class ram_driver;

  virtual ram_if vif;

  mailbox #(transaction) wr_mbox;
  mailbox #(transaction) rd_mbox;

  mailbox #(bit) wr_done_mbox;
  mailbox #(bit) rd_done_mbox;

  int unsigned wr_txn_count;
  int unsigned rd_txn_count;


  function new(
    virtual ram_if vif,
    mailbox #(transaction) wr_mbox,
    mailbox #(transaction) rd_mbox,
    mailbox #(bit) wr_done_mbox,
    mailbox #(bit) rd_done_mbox
  );

    this.vif          = vif;
    this.wr_mbox      = wr_mbox;
    this.rd_mbox      = rd_mbox;
    this.wr_done_mbox = wr_done_mbox;
    this.rd_done_mbox = rd_done_mbox;

    wr_txn_count = 0;
    rd_txn_count = 0;

  endfunction


  // RESET

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


  // WRITE DRIVER

  task write_drive(transaction txn);

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


  // READ DRIVER

  task read_drive(transaction txn);

    
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

  endtask


  // WRITE RUN

  task write_run();

    transaction txn;

    forever begin

      wr_mbox.get(txn);

      write_drive(txn);

      wr_txn_count++;

      wr_done_mbox.put(1'b1);

    end

  endtask


  // READ RUN

  task read_run();

    transaction txn;

    forever begin

      rd_mbox.get(txn);

      read_drive(txn);

      rd_txn_count++;

      // Tell testcase that READ is completed
      rd_done_mbox.put(1'b1);

    end

  endtask


  // RUN BOTH WRITE AND READ

  task run();

    fork

      write_run();
      read_run();

    join_none

  endtask


endclass


// MONITOR


class ram_monitor;

  virtual ram_if vif;


  mailbox #(transaction) mon_mbox;
mailbox #(transaction) cov_mbox;

 function new(
  virtual ram_if vif,
  mailbox #(transaction) mon_mbox,
  mailbox #(transaction) cov_mbox
);

  this.vif      = vif;
  this.mon_mbox = mon_mbox;
  this.cov_mbox = cov_mbox;

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
        cov_mbox.put(txn);
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
        cov_mbox.put(txn);
      end

    end

  endtask

endclass
// COVERAGE

class ram_coverage;

  mailbox #(transaction) cov_mbox;

  transaction txn;


  covergroup ram_cg;

    // Operation coverage

    cp_operation : coverpoint txn.op {
      bins write = {transaction::WRITE};
      bins read  = {transaction::READ};
    }


    // Address coverage

    cp_address : coverpoint txn.addr {
      bins address[] = {[0:127]};
    }


    // Block coverage

    cp_block : coverpoint txn.addr[6:5] {
      bins block0 = {2'b00};
      bins block1 = {2'b01};
      bins block2 = {2'b10};
      bins block3 = {2'b11};
    }


    // Word address coverage

    cp_word_addr : coverpoint txn.addr[4:0] {
      bins word_addr[] = {[0:31]};
    }


    // Data coverage

    cp_data : coverpoint txn.wdata {
      bins zero       = {8'h00};
      bins ones       = {8'hFF};
      bins aa_pattern = {8'hAA};
      bins pattern_55 = {8'h55};
      bins others     = default;
    }


    // Valid coverage

    cp_valid : coverpoint txn.valid {
      bins valid_0 = {1'b0};
      bins valid_1 = {1'b1};
    }


    // READ/WRITE × BLOCK

    operation_block : cross cp_operation, cp_block;

  endgroup


  function new(mailbox #(transaction) cov_mbox);

    this.cov_mbox = cov_mbox;

    ram_cg = new();

  endfunction


  task run();

    forever begin

      cov_mbox.get(txn);

      ram_cg.sample();

    end

  endtask


  function void report();

    $display("");
    $display("========================================");
    $display("       RAM FUNCTIONAL COVERAGE");
    $display("========================================");

    $display("Operation Coverage       = %0.2f%%",
             ram_cg.cp_operation.get_coverage());

    $display("Address Coverage         = %0.2f%%",
             ram_cg.cp_address.get_coverage());

    $display("Block Coverage           = %0.2f%%",
             ram_cg.cp_block.get_coverage());

    $display("Word Address Coverage    = %0.2f%%",
             ram_cg.cp_word_addr.get_coverage());

    $display("Data Coverage            = %0.2f%%",
             ram_cg.cp_data.get_coverage());

    $display("Valid Coverage           = %0.2f%%",
             ram_cg.cp_valid.get_coverage());

    $display("Operation × Block        = %0.2f%%",
             ram_cg.operation_block.get_coverage());

  endfunction

endclass

// AGENT

class ram_agent;

  ram_driver  drv;
  ram_monitor mon;

  function new(
  virtual ram_if vif,
  mailbox #(transaction) wr_mbox,
  mailbox #(transaction) rd_mbox,
  mailbox #(transaction) mon_mbox,
  mailbox #(transaction) cov_mbox,
  mailbox #(bit) wr_done_mbox,
  mailbox #(bit) rd_done_mbox
);

    drv = new(
      vif,
      wr_mbox,
      rd_mbox,
      wr_done_mbox,
      rd_done_mbox
    );

    mon = new(
      vif,
      mon_mbox,
      cov_mbox
    );

  endfunction

  task run();
    fork
      drv.run();
      mon.run();
    join_none
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

  function void reset_expected_memory();

    expected_mem.delete();

    $display("%0t : SCOREBOARD EXPECTED MEMORY RESET",
             $time);

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
  mailbox #(transaction) cov_mbox;
  
  mailbox #(bit) wr_done_mbox;
  mailbox #(bit) rd_done_mbox;// read driver mailbox


  ram_generator   gen;
  ram_agent       agent;
  ram_scoreboard  scb;
  ram_coverage    cov;

  function new(virtual ram_if vif);

    this.vif = vif;


    
    // Mailboxes
    

    wr_mbox      = new();
    rd_mbox      = new();
    mon_mbox     = new();
    cov_mbox     = new();
    wr_done_mbox = new();
    rd_done_mbox = new();


    
    // Components
gen = new(
  vif,
  wr_mbox,
  rd_mbox,
  wr_done_mbox,
  rd_done_mbox,
  10,
  10
);


    agent = new(
      vif,
      wr_mbox,
      rd_mbox,
      mon_mbox,
       cov_mbox,
      wr_done_mbox,
      rd_done_mbox
    );


    scb = new(
      mon_mbox
    );
    cov = new(
  cov_mbox
);
  endfunction


task run();

  $display("RAM ENVIRONMENT START");

  // Reset DUT
  agent.drv.reset();

  // Start verification components
  fork
    agent.run();
    scb.run();
    cov.run();
  join_none

  $display("RAM ENVIRONMENT READY");

endtask


    
    // Start generator
    

  //  gen.run();


  //  $display("GENERATOR COMPLETED");

  //endtask

endclass


// TEST

class ram_test;

  ram_environment env[10];

  virtual ram_if vif_array[10];

  //int current_env;
 // ram_environment current_env_handle;

function new(virtual ram_if vif_array_in[10]);

  this.vif_array = vif_array_in;

  foreach (env[i]) begin
    env[i] = new(vif_array_in[i]);
  end

endfunction

  task run();


    $display("       RAM TEST STARTED");

    // Start environment

      foreach (env[i]) begin
      automatic int idx = i;

      fork
        env[idx].run();
      join_none
    end

    wait fork;

    // Run TC01

    tc01_basic_write();

    // Run TC02

    tc02_basic_read();

    // Run TC03

    tc03_read_after_write();

    // Run TC04

    tc04_unwritten_read();

    // Run TC05

    tc05_block0();

    // Run TC06

    tc06_block1();

    // Run TC07

    tc07_block2();

    // Run TC08

    tc08_block3();

    // Run TC09

    tc09_multiple_writes();

    // Run TC10

    tc10_multiple_reads();

    // Run TC11

    tc11_read_write_activity();

    // Run TC12

    tc12_all_environments();

    // Run TC13

    tc13_read_write_enable();

    // Run TC14

    tc14_reset_test();

    // Run TC15

    tc15_write_after_read();

       // Run TC18

    tc18_data_pattern();
      
//       // TC19 : CODE COVERAGE TEST

   tc19_code_coverage();
      
 // TC20 : CODE COVERAGE TEST
      tc20_toggle_coverage();
      
    #1000;
      


    // Scoreboard report

    foreach (env[i]) begin

      $display("");
      $display("******** ENVIRONMENT %0d ********", i);

      env[i].scb.report();
      env[i].cov.report();
    end

    $display("       RAM TEST FINISHED");

  endtask


  // TC01 : BASIC WRITE

  task tc01_basic_write();

    transaction txn;
    bit done;

    $display("");
    $display(" TC01 : BASIC WRITE");

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h10;
    txn.wdata = 8'hAA;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);
    txn = new();

txn.op   = transaction::READ;
txn.addr = 7'h10;

env[0].rd_mbox.put(txn);

env[0].rd_done_mbox.get(done);
    
$display("%0t : TC01 WRITE + READ COMPLETED : ADDR=%0h",
         $time,
         7'h10);

  endtask


  // TC02 : BASIC READ

  task tc02_basic_read();

    transaction txn;
    bit done;

    $display("");
    $display(" TC02 : BASIC READ");

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h20;
    txn.wdata = 8'h55;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);

    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h20;

    env[0].rd_mbox.put(txn);

    env[0].rd_done_mbox.get(done);

    $display("%0t : TC02 READ COMPLETED : ADDR=%0h",
             $time,
             txn.addr);

  endtask


  // TC03 : READ AFTER WRITE

  task tc03_read_after_write();

    transaction txn;
    bit done;

    $display("");
    $display(" TC03 : READ AFTER WRITE");

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h10;
    txn.wdata = 8'hAA;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);

    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h10;

    env[0].rd_mbox.put(txn);

    env[0].rd_done_mbox.get(done);

    $display("%0t : TC03 READ COMPLETED : ADDR=%0h",
             $time,
             txn.addr);

  endtask


  // TC04 : UNWRITTEN READ

  task tc04_unwritten_read();

    transaction txn;
    bit done;

    $display("");
    $display(" TC04 : UNWRITTEN READ");

    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h50;

    env[0].rd_mbox.put(txn);

    env[0].rd_done_mbox.get(done);

    $display("%0t : TC04 UNWRITTEN READ COMPLETED : ADDR=%0h",
             $time,
             txn.addr);

  endtask


  // TC05 : BLOCK 0

  task tc05_block0();

    transaction txn;
    bit done;

    $display("");
    $display(" TC05 : BLOCK 0");

    for (int i = 0; i < 32; i++) begin

      txn = new();

      txn.op    = transaction::WRITE;
      txn.addr  = i;
      txn.wdata = i;

      env[0].wr_mbox.put(txn);

      env[0].wr_done_mbox.get(done);

    end

    for (int i = 0; i < 32; i++) begin

      txn = new();

      txn.op   = transaction::READ;
      txn.addr = i;

      env[0].rd_mbox.put(txn);

      env[0].rd_done_mbox.get(done);

    end

    $display("TC05 : BLOCK 0 COMPLETED");

  endtask


  // TC06 : BLOCK 1

  task tc06_block1();

    transaction txn;
    bit done;

    $display("");
    $display(" TC06 : BLOCK 1");

    for (int i = 32; i < 64; i++) begin

      txn = new();

      txn.op    = transaction::WRITE;
      txn.addr  = i;
      txn.wdata = i;

      env[0].wr_mbox.put(txn);

      env[0].wr_done_mbox.get(done);

    end

    for (int i = 32; i < 64; i++) begin

      txn = new();

      txn.op   = transaction::READ;
      txn.addr = i;

      env[0].rd_mbox.put(txn);

      env[0].rd_done_mbox.get(done);

    end

    $display("TC06 : BLOCK 1 COMPLETED");

  endtask


  // TC07 : BLOCK 2

  task tc07_block2();

    transaction txn;
    bit done;

    $display("");
    $display(" TC07 : BLOCK 2");

    for (int i = 64; i < 96; i++) begin

      txn = new();

      txn.op    = transaction::WRITE;
      txn.addr  = i;
      txn.wdata = i;

      env[0].wr_mbox.put(txn);

      env[0].wr_done_mbox.get(done);

    end

    for (int i = 64; i < 96; i++) begin

      txn = new();

      txn.op   = transaction::READ;
      txn.addr = i;

      env[0].rd_mbox.put(txn);

      env[0].rd_done_mbox.get(done);

    end

    $display("TC07 : BLOCK 2 COMPLETED");

  endtask


  // TC08 : BLOCK 3

  task tc08_block3();

    transaction txn;
    bit done;

    $display("");
    $display(" TC08 : BLOCK 3");

    for (int i = 96; i < 128; i++) begin

      txn = new();

      txn.op    = transaction::WRITE;
      txn.addr  = i;
      txn.wdata = i;

      env[0].wr_mbox.put(txn);

      env[0].wr_done_mbox.get(done);

    end

    for (int i = 96; i < 128; i++) begin

      txn = new();

      txn.op   = transaction::READ;
      txn.addr = i;

      env[0].rd_mbox.put(txn);

      env[0].rd_done_mbox.get(done);

    end

    $display("TC08 : BLOCK 3 COMPLETED");

  endtask


  // TC09 : MULTIPLE WRITES

  task tc09_multiple_writes();

    transaction txn;
    bit done;

    $display("");
    $display(" TC09 : MULTIPLE WRITES");

    for (int i = 0; i < 10; i++) begin

      txn = new();

      txn.op    = transaction::WRITE;
      txn.addr  = i * 3;
      txn.wdata = 8'hA0 + i;

      env[0].wr_mbox.put(txn);

      env[0].wr_done_mbox.get(done);

    end

    $display("TC09 : MULTIPLE WRITES COMPLETED");

  endtask


  // TC10 : MULTIPLE READS

  task tc10_multiple_reads();

    transaction txn;
    bit done;

    $display("");
    $display(" TC10 : MULTIPLE READS");

    for (int i = 0; i < 10; i++) begin

      txn = new();

      txn.op    = transaction::WRITE;
      txn.addr  = i * 2;
      txn.wdata = 8'h50 + i;

      env[0].wr_mbox.put(txn);

      env[0].wr_done_mbox.get(done);

    end

    for (int i = 0; i < 10; i++) begin

      txn = new();

      txn.op   = transaction::READ;
      txn.addr = i * 2;

      env[0].rd_mbox.put(txn);

      env[0].rd_done_mbox.get(done);

    end

    $display("TC10 : MULTIPLE READS COMPLETED");

  endtask


  // TC11 : READ WRITE ACTIVITY

  task tc11_read_write_activity();

    transaction txn;
    bit done;

    $display("");
    $display(" TC11 : READ WRITE ACTIVITY");

    for (int i = 0; i < 10; i++) begin

      txn = new();

      txn.op    = transaction::WRITE;
      txn.addr  = i + 40;
      txn.wdata = 8'h80 + i;

      env[0].wr_mbox.put(txn);

      env[0].wr_done_mbox.get(done);

      txn = new();

      txn.op   = transaction::READ;
      txn.addr = i + 40;

      env[0].rd_mbox.put(txn);

      env[0].rd_done_mbox.get(done);

    end

    $display("TC11 : READ WRITE ACTIVITY COMPLETED");

  endtask

  // TC12 : ALL ENVIRONMENTS

  task tc12_all_environments();

    transaction txn[10];
    bit done[10];

    $display("");
    $display(" TC12 : ALL ENVIRONMENTS");

    fork

      begin

        txn[0] = new();
        txn[0].op    = transaction::WRITE;
        txn[0].addr  = 7'h70;
        txn[0].wdata = 8'hAA;

        env[0].wr_mbox.put(txn[0]);
        env[0].wr_done_mbox.get(done[0]);

        txn[0] = new();
        txn[0].op   = transaction::READ;
        txn[0].addr = 7'h70;

        env[0].rd_mbox.put(txn[0]);
        env[0].rd_done_mbox.get(done[0]);

        $display("TC12 : ENVIRONMENT 0 COMPLETED");

      end

      begin

        txn[1] = new();
        txn[1].op    = transaction::WRITE;
        txn[1].addr  = 7'h70;
        txn[1].wdata = 8'hAB;

        env[1].wr_mbox.put(txn[1]);
        env[1].wr_done_mbox.get(done[1]);

        txn[1] = new();
        txn[1].op   = transaction::READ;
        txn[1].addr = 7'h70;

        env[1].rd_mbox.put(txn[1]);
        env[1].rd_done_mbox.get(done[1]);

        $display("TC12 : ENVIRONMENT 1 COMPLETED");

      end

      begin

        txn[2] = new();
        txn[2].op    = transaction::WRITE;
        txn[2].addr  = 7'h70;
        txn[2].wdata = 8'hAC;

        env[2].wr_mbox.put(txn[2]);
        env[2].wr_done_mbox.get(done[2]);

        txn[2] = new();
        txn[2].op   = transaction::READ;
        txn[2].addr = 7'h70;

        env[2].rd_mbox.put(txn[2]);
        env[2].rd_done_mbox.get(done[2]);

        $display("TC12 : ENVIRONMENT 2 COMPLETED");

      end

      begin

        txn[3] = new();
        txn[3].op    = transaction::WRITE;
        txn[3].addr  = 7'h70;
        txn[3].wdata = 8'hAD;

        env[3].wr_mbox.put(txn[3]);
        env[3].wr_done_mbox.get(done[3]);

        txn[3] = new();
        txn[3].op   = transaction::READ;
        txn[3].addr = 7'h70;

        env[3].rd_mbox.put(txn[3]);
        env[3].rd_done_mbox.get(done[3]);

        $display("TC12 : ENVIRONMENT 3 COMPLETED");

      end

      begin

        txn[4] = new();
        txn[4].op    = transaction::WRITE;
        txn[4].addr  = 7'h70;
        txn[4].wdata = 8'hAE;

        env[4].wr_mbox.put(txn[4]);
        env[4].wr_done_mbox.get(done[4]);

        txn[4] = new();
        txn[4].op   = transaction::READ;
        txn[4].addr = 7'h70;

        env[4].rd_mbox.put(txn[4]);
        env[4].rd_done_mbox.get(done[4]);

        $display("TC12 : ENVIRONMENT 4 COMPLETED");

      end

      begin

        txn[5] = new();
        txn[5].op    = transaction::WRITE;
        txn[5].addr  = 7'h70;
        txn[5].wdata = 8'hAF;

        env[5].wr_mbox.put(txn[5]);
        env[5].wr_done_mbox.get(done[5]);

        txn[5] = new();
        txn[5].op   = transaction::READ;
        txn[5].addr = 7'h70;

        env[5].rd_mbox.put(txn[5]);
        env[5].rd_done_mbox.get(done[5]);

        $display("TC12 : ENVIRONMENT 5 COMPLETED");

      end

      begin

        txn[6] = new();
        txn[6].op    = transaction::WRITE;
        txn[6].addr  = 7'h70;
        txn[6].wdata = 8'hB0;

        env[6].wr_mbox.put(txn[6]);
        env[6].wr_done_mbox.get(done[6]);

        txn[6] = new();
        txn[6].op   = transaction::READ;
        txn[6].addr = 7'h70;

        env[6].rd_mbox.put(txn[6]);
        env[6].rd_done_mbox.get(done[6]);

        $display("TC12 : ENVIRONMENT 6 COMPLETED");

      end

      begin

        txn[7] = new();
        txn[7].op    = transaction::WRITE;
        txn[7].addr  = 7'h70;
        txn[7].wdata = 8'hB1;

        env[7].wr_mbox.put(txn[7]);
        env[7].wr_done_mbox.get(done[7]);

        txn[7] = new();
        txn[7].op   = transaction::READ;
        txn[7].addr = 7'h70;

        env[7].rd_mbox.put(txn[7]);
        env[7].rd_done_mbox.get(done[7]);

        $display("TC12 : ENVIRONMENT 7 COMPLETED");

      end

      begin

        txn[8] = new();
        txn[8].op    = transaction::WRITE;
        txn[8].addr  = 7'h70;
        txn[8].wdata = 8'hB2;

        env[8].wr_mbox.put(txn[8]);
        env[8].wr_done_mbox.get(done[8]);

        txn[8] = new();
        txn[8].op   = transaction::READ;
        txn[8].addr = 7'h70;

        env[8].rd_mbox.put(txn[8]);
        env[8].rd_done_mbox.get(done[8]);

        $display("TC12 : ENVIRONMENT 8 COMPLETED");

      end

      begin

        txn[9] = new();
        txn[9].op    = transaction::WRITE;
        txn[9].addr  = 7'h70;
        txn[9].wdata = 8'hB3;

        env[9].wr_mbox.put(txn[9]);
        env[9].wr_done_mbox.get(done[9]);

        txn[9] = new();
        txn[9].op   = transaction::READ;
        txn[9].addr = 7'h70;

        env[9].rd_mbox.put(txn[9]);
        env[9].rd_done_mbox.get(done[9]);

        $display("TC12 : ENVIRONMENT 9 COMPLETED");

      end

    join

    $display("TC12 : ALL ENVIRONMENTS COMPLETED");

  endtask
  


  // TC13 : READ WRITE ENABLE

  task tc13_read_write_enable();

    transaction txn;
    bit done;

    $display("");
    $display(" TC13 : READ WRITE ENABLE");

    // WRITE ENABLED

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h30;
    txn.wdata = 8'hAA;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);

    // READ ENABLED

    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h30;

    env[0].rd_mbox.put(txn);

    env[0].rd_done_mbox.get(done);

    // ENABLE DEASSERTED

    @(negedge env[0].vif.clk);

    env[0].vif.w_enb = 1'b0;
    env[0].vif.r_enb = 1'b0;
    env[0].vif.addr  = 7'h30;
    env[0].vif.wdata = 8'h55;

    @(posedge env[0].vif.clk);

    @(negedge env[0].vif.clk);

    $display("TC13 : READ/WRITE ENABLE TEST COMPLETED");

  endtask


  // TC14 : RESET TEST

   // TC14 : RESET TEST

  task tc14_reset_test();

    transaction txn;
    bit done;
    logic [7:0] reset_rdata;
    bit reset_valid;

    $display("");
    $display(" TC14 : RESET TEST");

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h40;
    txn.wdata = 8'hAA;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);

    $display("TC14 : DATA WRITTEN BEFORE RESET");

    env[0].vif.rst_n = 1'b0;

    env[0].vif.w_enb = 1'b0;
    env[0].vif.r_enb = 1'b0;
    env[0].vif.addr  = 7'h00;
    env[0].vif.wdata = 8'h00;

    repeat(4)
      @(posedge env[0].vif.clk);

    env[0].vif.rst_n = 1'b1;

    $display("TC14 : RESET COMPLETED");
    env[0].scb.reset_expected_memory();

    // Read after reset to verify memory was cleared

    @(negedge env[0].vif.clk);

    env[0].vif.addr  = 7'h40;
    env[0].vif.r_enb = 1'b1;

    @(posedge env[0].vif.clk);

    #1;

    reset_rdata = env[0].vif.rdata;
    reset_valid = env[0].vif.valid;

    @(negedge env[0].vif.clk);

    env[0].vif.r_enb = 1'b0;

    if (reset_valid && (reset_rdata == 8'h00))
      $display("TC14 PASS : MEMORY CLEARED AFTER RESET");
    else
      $display("TC14 FAIL : RESET MEMORY CHECK FAILED. DATA=%h VALID=%b",
               reset_rdata, reset_valid);

  endtask

  // TC15 : WRITE AFTER READ

  task tc15_write_after_read();

    transaction txn;
    bit done;

    $display("");
    $display(" TC15 : WRITE AFTER READ");

    // First write initial data

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h60;
    txn.wdata = 8'hAA;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);

    // Read address

    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h60;

    env[0].rd_mbox.put(txn);

    env[0].rd_done_mbox.get(done);

    // Write new data

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h60;
    txn.wdata = 8'h55;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);

    // Read updated data

    txn = new();

    txn.op   = transaction::READ;
    txn.addr = 7'h60;

    env[0].rd_mbox.put(txn);

    env[0].rd_done_mbox.get(done);

    $display("TC15 : WRITE AFTER READ COMPLETED");

  endtask
  // TC18 : DATA PATTERN TEST

  task tc18_data_pattern();

    transaction txn;
    bit done;

    $display("");
    $display(" TC18 : DATA PATTERN TEST");

    // DATA 00

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h01;
    txn.wdata = 8'h00;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);


    // DATA FF

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h02;
    txn.wdata = 8'hFF;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);


    // DATA AA

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h03;
    txn.wdata = 8'hAA;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);


    // DATA 55

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h04;
    txn.wdata = 8'h55;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);


    // DATA OTHER

    txn = new();

    txn.op    = transaction::WRITE;
    txn.addr  = 7'h05;
    txn.wdata = 8'h3C;

    env[0].wr_mbox.put(txn);

    env[0].wr_done_mbox.get(done);
 


    $display("TC18 : DATA PATTERN TEST COMPLETED");
 endtask
      
      // TC19 : CODE COVERAGE TEST

task tc19_code_coverage();

  transaction txn;
  bit done;

  $display("");
  $display("========================================");
  $display(" TC19 : CODE COVERAGE TEST");
  $display("========================================");

  // Run same coverage stimulus on all 10 environments

  for (int e = 0; e < 10; e++) begin

    $display("");
    $display("TC19 : ENVIRONMENT %0d", e);

    
    // WRITE BLOCK 0
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h00;
    txn.wdata = 8'h11;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);


    // WRITE BLOCK 1
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h20;
    txn.wdata = 8'h22;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);


    // WRITE BLOCK 2
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h40;
    txn.wdata = 8'h33;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);


    // 
    // WRITE BLOCK 3
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h60;
    txn.wdata = 8'h44;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);


    // READ BLOCK 0
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h00;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);


    // READ BLOCK 1
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h20;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);


    // READ BLOCK 2
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h40;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);


    // READ BLOCK 3
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h60;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);


    // IDLE CONDITION
    @(negedge env[e].vif.clk);

    env[e].vif.w_enb = 1'b0;
    env[e].vif.r_enb = 1'b0;
    env[e].vif.addr  = 7'h00;
    env[e].vif.wdata = 8'h00;

    @(posedge env[e].vif.clk);

    @(negedge env[e].vif.clk);

    $display("TC19 : ENVIRONMENT %0d COMPLETED", e);

  end

  $display("TC19 : CODE COVERAGE TEST COMPLETED");

endtask
// TC20 : TOGGLE COVERAGE TEST

task tc20_toggle_coverage();

  transaction txn;
  bit done;

  
  $display("========================================");
  $display(" TC20 : TOGGLE COVERAGE TEST");
  $display("========================================");

  for (int e = 0; e < 10; e++) begin

    $display("");
    $display("TC20 : ENVIRONMENT %0d", e);

    // ADDRESS 00, DATA 00
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h00;
    txn.wdata = 8'h00;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);

    // ADDRESS 7F, DATA FF
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h7F;
    txn.wdata = 8'hFF;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);

    // ADDRESS 20, DATA AA
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h20;
    txn.wdata = 8'hAA;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);

    // ADDRESS 3F, DATA 55
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h3F;
    txn.wdata = 8'h55;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);

    // ADDRESS 40, DATA 0F
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h40;
    txn.wdata = 8'h0F;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);

    // ADDRESS 5F, DATA F0
    txn = new();
    txn.op    = transaction::WRITE;
    txn.addr  = 7'h5F;
    txn.wdata = 8'hF0;

    env[e].wr_mbox.put(txn);
    env[e].wr_done_mbox.get(done);

    // READ ADDRESS 00
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h00;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);

    // READ ADDRESS 7F
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h7F;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);

    // READ ADDRESS 20
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h20;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);

    // READ ADDRESS 3F
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h3F;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);

    // READ ADDRESS 40
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h40;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);

    // READ ADDRESS 5F
    txn = new();
    txn.op   = transaction::READ;
    txn.addr = 7'h5F;

    env[e].rd_mbox.put(txn);
    env[e].rd_done_mbox.get(done);

    $display("TC20 : ENVIRONMENT %0d COMPLETED", e);

  end

  $display("TC20 : TOGGLE COVERAGE TEST COMPLETED");

endtask
endclass



// TOP TESTBENCH


module tb;

  logic clk;

  ram_if vif[10](clk);// 10 created interface
  virtual ram_if vif_array[10];


  
  // DUT
  

  genvar i;
  generate

    for (i = 0; i < 10; i++) begin : DUT_GEN

      decoder_ram dut (

        .clk   (clk),
        .rst_n (vif[i].rst_n),
        .w_enb (vif[i].w_enb),
        .r_enb (vif[i].r_enb),
        .addr  (vif[i].addr),
        .wdata (vif[i].wdata),
        .rdata (vif[i].rdata),
        .valid (vif[i].valid)

      );

    end

  endgenerate


  genvar j;
  generate

    for (j = 0; j < 10; j++) begin : VIF_CONNECT

      initial begin
        vif_array[j] = vif[j];
      end

    end

  endgenerate


  
  // ENVIRONMENT and TEST CASE
  

  ram_test test;



  
  // CLOCK
  

  initial begin

    clk = 1'b0;

    forever
      #5 clk = ~clk;

  end


  
  // TEST
  
  initial begin

    $dumpfile("waveform.vcd");
    $dumpvars(0, tb);

    $display("");
    $display("RAM TEST STARTED");


    // Create test

    test = new(vif_array);


    // Start test

    test.run();

$stop;

  end

endmodule
