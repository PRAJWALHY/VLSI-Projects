`timescale 1ns/1ps

module tb;

    // APB SIGNALS
    logic        PCLK;
    logic        PRESETn;

    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;

    logic [31:0] PADDR;
    logic [31:0] PWDATA;

    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;


    // DUT

    apb_slave dut (
        .PCLK    (PCLK),
        .PRESETn (PRESETn),
        .PSEL    (PSEL),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA),
        .PREADY  (PREADY),
        .PSLVERR (PSLVERR)
    );


    // CLOCK

    initial begin
        PCLK = 1'b0;
        forever #5 PCLK = ~PCLK;
    end


    // RESET

    initial begin

        PRESETn = 1'b0;

        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
        PADDR   = 32'd0;
        PWDATA  = 32'd0;

        repeat (2)
            @(posedge PCLK);

        PRESETn = 1'b1;

    end


    // APB WRITE TASK

    task apb_write(
        input logic [31:0] addr,
        input logic [31:0] data
    );

        begin

            // SETUP
            @(posedge PCLK);

            PSEL    <= 1'b1;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b1;
            PADDR   <= addr;
            PWDATA  <= data;

            // ACCESS
            @(posedge PCLK);

            PENABLE <= 1'b1;

            // Wait for slave
            wait(PREADY == 1'b1);

            // Complete transaction
            @(posedge PCLK);

            $display(
                "[%0t] WRITE addr=%0d data=%0h PSLVERR=%0b",
                $time,
                addr,
                data,
                PSLVERR
            );

            // IDLE
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;

        end

    endtask


    // APB READ TASK

    task apb_read(
        input logic [31:0] addr
    );

        begin

            // SETUP
            @(posedge PCLK);

            PSEL    <= 1'b1;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;
            PADDR   <= addr;

            // ACCESS
            @(posedge PCLK);

            PENABLE <= 1'b1;

            // Wait for slave
            wait(PREADY == 1'b1);

            // Complete transaction
            @(posedge PCLK);

            $display(
                "[%0t] READ addr=%0d data=%0h PSLVERR=%0b",
                $time,
                addr,
                PRDATA,
                PSLVERR
            );

            // IDLE
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;

        end

    endtask


    // MAIN TEST
    initial begin

        wait(PRESETn == 1'b1);

        @(posedge PCLK);

        $display("  APB TEST START");

        // 1. WRITE
        apb_write(
            32'd200,
            32'hAAAA_BBBB
        );


        // 2. READ
        apb_read(32'd200);


        // 3. READ-ONLY REGION
        apb_read(32'd20);


        // 4. WRITE-ONLY REGION
        apb_write(
            32'd120,
            32'h1234_5678
        );


        // 5. INVALID ADDRESS
        apb_read(32'd300);


        $display("APB TEST END");


        #20;

        $display("Simulation completed.");
//==================================================
// INTENTIONAL VIOLATION TEST - ASSERTION #1
// PENABLE HIGH while PSEL LOW
//==================================================

// $display("======================================");
// $display(" ASSERTION #1 - PENABLE/PSEL VIOLATION");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b0;
// PENABLE = 1'b1;
// PWRITE  = 1'b0;
// PADDR   = 32'd200;

// $display("[%0t] PSEL=0 PENABLE=1", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #1 SHOULD FAIL", $time);

// #10;

// $display("Assertion #1 violation test completed");

// $finish;
      
//==================================================
// INTENTIONAL SETUP -> ACCESS VIOLATION ----2nd  assertion 
//==================================================
      
$display("======================================");
$display(" SETUP -> ACCESS VIOLATION TEST");
$display("======================================");

@(negedge PCLK);

PSEL    = 1'b1;
PENABLE = 1'b0;
PWRITE  = 1'b0;
PADDR   = 32'd200;

$display("[%0t] SETUP driven", $time);

@(posedge PCLK);

$display("[%0t] SETUP sampled", $time);

@(negedge PCLK);

PSEL    = 1'b0;// for 2nd assertion creating both signals to zero
PENABLE = 1'b0;

$display("[%0t] IDLE driven", $time);

@(posedge PCLK);

$display("[%0t] IDLE sampled - ASSERTION SHOULD FAIL", $time);

#10;

$display("Assertion #2 violation test completed");

$finish;
      
// ==================================================
// ASSERTION #3 VIOLATION
// ACCESS -> PREADY
// ==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #3 - ACCESS TO READY VIOLATION");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b0;
// PADDR   = 32'd200;

// $display("[%0t] SETUP driven", $time);

// @(negedge PCLK);

// PENABLE = 1'b1;

// force PREADY = 1'b0;

// $display("[%0t] ACCESS driven", $time);
// $display("[%0t] PREADY forced LOW", $time);

// @(posedge PCLK);

// $display("[%0t] ACCESS sampled", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #3 SHOULD FAIL", $time);

// release PREADY;

// #10;

// $display("Assertion #3 violation test completed");

// $finish;
      
//==================================================
//INTENTIONAL PADDR STABILITY VIOLATION  ----4th assertion 
//==================================================

// $display("");
// $display("======================================");
// $display(" PADDR STABILITY VIOLATION TEST");
// $display("======================================");

// // SETUP

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b0;
// PADDR   = 32'd200;

// $display("[%0t] SETUP: PADDR = %0d", $time, PADDR);


// // ACCESS
// // Change PADDR intentionally

// @(negedge PCLK);

// PENABLE = 1'b1;
// PADDR   = 32'd300;

// $display("[%0t] ACCESS: PADDR changed to %0d", $time, PADDR);


// // Let SVA sample ACCESS

// @(posedge PCLK);

// $display("[%0t] ACCESS sampled - ASSERTION #4 SHOULD FAIL", $time);

// #10;

// $display("Assertion #4 violation test completed");

// $finish;
    
//==================================================
//INTENTIONAL PWRITE STABILITY VIOLATION  ----5th assertion 
//==================================================
      
// $display("======================================");
// $display(" PWRITE STABILITY VIOLATION TEST");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b1;
// PADDR   = 32'd120;
// PWDATA  = 32'h1234_5678;

// $display("[%0t] SETUP: PWRITE = %0b", $time, PWRITE);

// @(posedge PCLK);

// $display("[%0t] SETUP sampled", $time);

// @(negedge PCLK);

// PENABLE = 1'b1;
// PWRITE  = 1'b0;       // INTENTIONAL VIOLATION

// $display("[%0t] ACCESS: PWRITE changed to %0b", $time, PWRITE);

// @(posedge PCLK);

// $display("[%0t] ACCESS sampled - ASSERTION #5 SHOULD FAIL", $time);

// #10;

//$display("Assertion #5 violation test completed");
      //       $finish;
      
////  ==================================================
//////INTENTIONAL PWDATA STABILITY VIOLATION  ----6th assertion     
   //////==================================================

// $display("======================================");
// $display(" PWDATA STABILITY VIOLATION TEST");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b1;
// PADDR   = 32'd120;
// PWDATA  = 32'hAAAA_BBBB;

// $display("[%0t] SETUP: PWDATA = %0h", $time, PWDATA);

// @(posedge PCLK);

// $display("[%0t] SETUP sampled", $time);

// @(negedge PCLK);

// PENABLE = 1'b1;
// PWDATA  = 32'hCCCC_DDDD;   // INTENTIONAL VIOLATION

// $display("[%0t] ACCESS: PWDATA changed to %0h", $time, PWDATA);

// @(posedge PCLK);

// $display("[%0t] ACCESS sampled - ASSERTION #6 SHOULD FAIL", $time);

// #10;

// $display("Assertion #6 violation test completed");
   

//  $finish;
      
//==================================================
// INTENTIONAL VIOLATION TEST - ASSERTION #7
// PSEL rises while PENABLE is HIGH   to run 7 u have to comment 1st assertion
//==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #7 - PSEL RISE VIOLATION");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b0;
// PENABLE = 1'b1;

// $display("[%0t] Initial: PSEL=0 PENABLE=1", $time);

// @(negedge PCLK);

// PSEL = 1'b1;

// $display("[%0t] PSEL changed 0 -> 1 while PENABLE=1", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #7 SHOULD FAIL", $time);

// #10;

// $display("Assertion #7 violation test completed");

// $finish;
      
      
//==================================================
// INTENTIONAL VIOLATION TEST - ASSERTION #8
// PSEL falls while PENABLE is HIGH
//==================================================

// $display("======================================");
// $display(" ASSERTION #8 - PSEL FALL VIOLATION");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b1;

// $display("[%0t] Initial: PSEL=1 PENABLE=1", $time);

// @(negedge PCLK);

// PSEL = 1'b0;

// $display("[%0t] PSEL changed 1 -> 0 while PENABLE=1", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #8 SHOULD FAIL", $time);

// #10;

// $display("Assertion #8 violation test completed");

// $finish;
      
      
//==================================================
// ASSERTION #9 VIOLATION TEST
// PADDR CHANGES BETWEEN TWO ACCESS CYCLES
//==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #9 - PADDR PREVIOUS CYCLE VIOLATION");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b1;
// PWRITE  = 1'b0;
// PADDR   = 32'd200;

// $display("[%0t] ACCESS cycle 1: PADDR=200", $time);

// @(posedge PCLK);

// $display("[%0t] ACCESS cycle 1 sampled", $time);

// @(negedge PCLK);

// PADDR = 32'd300;

// $display("[%0t] ACCESS cycle 2: PADDR=300", $time);

// @(posedge PCLK);

// $display("[%0t] ACCESS cycle 2 sampled - ASSERTION #9 SHOULD FAIL", $time);

// @(posedge PCLK);

// PSEL    = 1'b0;
// PENABLE = 1'b0;
// PWRITE  = 1'b0;

// $display("Assertion #9 violation test completed");

// #10;

// $finish;
      
      
 //==================================================
// INTENTIONAL VIOLATION TEST - ASSERTION #12
// PREADY not received within 3 cycles
//==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #12 - PREADY TIMEOUT");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b1;
// PWRITE  = 1'b0;
// PADDR   = 32'd200;

// force PREADY = 1'b0;

// $display("[%0t] ACCESS driven, PREADY forced LOW", $time);

// repeat(4)
//     @(posedge PCLK);

// $display("[%0t] ASSERTION #12 SHOULD FAIL", $time);

// release PREADY;

// #10;

// $display("Assertion #12 violation test completed");

// $finish;     
      
//==================================================
// ASSERTION #13 VIOLATION
// RESET OUTPUT VIOLATION
//==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #13 - RESET OUTPUT VIOLATION");
// $display("======================================");

// PRESETn = 1'b0;

// force PREADY  = 1'b1;
// force PSLVERR = 1'b0;

// $display("[%0t] RESET active", $time);
// $display("[%0t] PREADY forced HIGH", $time);

// repeat(2)
//     @(posedge PCLK);

// $display("[%0t] ASSERTION #13 SHOULD FAIL", $time);

// release PREADY;
// release PSLVERR;

// #10;

// $display("Assertion #13 violation test completed");

// $finish;
      
//==================================================
// ASSERTION #14 VIOLATION
// WRITE TO READ-ONLY REGION
//==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #14 - READ ONLY WRITE ERROR");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b1;
// PADDR   = 32'd20;
// PWDATA  = 32'hAAAA_BBBB;

// @(negedge PCLK);

// PENABLE = 1'b1;

// $display("[%0t] WRITE to read-only address 20", $time);

// @(posedge PCLK);

// force PSLVERR = 1'b0;

// $display("[%0t] PSLVERR forced LOW", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #14 SHOULD FAIL", $time);

// release PSLVERR;

// #10;

// $display("Assertion #14 violation test completed");

// $finish;
      
//==================================================
// ASSERTION #15 VIOLATION
// READ FROM WRITE-ONLY REGION
//==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #15 - WRITE ONLY READ ERROR");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b0;
// PADDR   = 32'd120;

// @(negedge PCLK);

// PENABLE = 1'b1;

// $display("[%0t] READ from write-only address 120", $time);

// @(posedge PCLK);

// force PSLVERR = 1'b0;

// $display("[%0t] PSLVERR forced LOW", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #15 SHOULD FAIL", $time);

// release PSLVERR;

// #10;

// $display("Assertion #15 violation test completed");

// $finish;
  
//==================================================
// ASSERTION #16 VIOLATION
// INVALID ADDRESS
//==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #16 - INVALID ADDRESS ERROR");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b0;
// PADDR   = 32'd300;

// @(negedge PCLK);

// PENABLE = 1'b1;

// $display("[%0t] Invalid address = 300", $time);

// @(posedge PCLK);

// force PSLVERR = 1'b0;

// $display("[%0t] PSLVERR forced LOW", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #16 SHOULD FAIL", $time);

// release PSLVERR;

// #10;

// $display("Assertion #16 violation test completed");

// $finish;
      
// //==================================================
// // INTENTIONAL VIOLATION TEST - ASSERTION #17
// // Valid READ incorrectly generates PSLVERR
// //==================================================

// $display("");
// $display("======================================");
// $display(" ASSERTION #17 - VALID READ ERROR");
// $display("======================================");

// @(negedge PCLK);

// PSEL    = 1'b1;
// PENABLE = 1'b0;
// PWRITE  = 1'b0;
// PADDR   = 32'd200;

// @(negedge PCLK);

// PENABLE = 1'b1;

// force PSLVERR = 1'b1;

// $display("[%0t] Valid READ address = 200", $time);
// $display("[%0t] PSLVERR forced HIGH", $time);

// @(posedge PCLK);

// $display("[%0t] ASSERTION #17 SHOULD FAIL", $time);

// #10;

// release PSLVERR;

// $display("Assertion #17 violation test completed");

$finish;
      
    end


   /////////////////////////////// // SVA ASSERTION #1
    //
    // PENABLE -> PSEL
    
    // If PENABLE is HIGH, PSEL must be HIGH
    // in the SAME clock cycle.
    

    property p_penable_requires_psel;

        @(posedge PCLK)
        disable iff (!PRESETn)

        PENABLE |-> PSEL;// in the same cycle both psel and penb should be high =1

    endproperty


    assert property (p_penable_requires_psel)

        else $error(
            "APB ERROR: PENABLE is HIGH while PSEL is LOW"
        );


   //////////////////////////// // SVA ASSERTION #2
    //
    // SETUP -> ACCESS

    // SETUP:
    // PSEL=1, PENABLE=0

    // Next cycle:
    // PSEL=1, PENABLE=1

    property p_setup_to_access;

        @(posedge PCLK)
        disable iff (!PRESETn)

      (PSEL && !PENABLE)  // here we are checking what happens when psel also get low it should go to the idle phase rather than going to accessed phase so we have added voilation check for this
        |=>
        (PSEL && PENABLE);

    endproperty


    assert property (p_setup_to_access)

        else $error(
            "APB ERROR: SETUP was not followed by ACCESS"
        );
      
/////////////////////////////////// SVA ASSERTION #3
// ACCESS -> PREADY

// If ACCESS happens,
// PREADY must be HIGH in the next clock.

 property p_access_to_ready;

    @(posedge PCLK)
    disable iff (!PRESETn)

    (PSEL && PENABLE)
    |=>
    PREADY;

endproperty


assert property (p_access_to_ready)

    else $error(
        "APB ERROR: ACCESS was not followed by PREADY"
    );
  
////////////////////////////////////// ASSERTION #4
  
// PADDR STABLe adderss is not being stable for transfer

property p_addr_stable_setup_to_access;

    @(posedge PCLK)
    disable iff (!PRESETn)

    (PSEL && !PENABLE)
    |=>
  $stable(PADDR);/// frequently check gor the PADDR where 

endproperty

assert property (p_addr_stable_setup_to_access)
    else $error(
        "APB ERROR: PADDR changed from SETUP to ACCESS"
    );
/////////////////////////////////// ASSERTION #5
  
////////If this clock is SETUP, then at the next clock PWRITE must be unchanged.

  
  property p_write_stable_setup_to_access;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && !PENABLE) |=> $stable(PWRITE);
endproperty

assert property (p_write_stable_setup_to_access)
    else $error("APB ERROR: PWRITE changed from SETUP to ACCESS");
  
  
////////////////////////////////////////////// ASSERTION #6 
  
  ///////////////////////////////////// PWDATA STABILITY

property p_wdata_stable_setup_to_access;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && !PENABLE && PWRITE) |=> $stable(PWDATA);
endproperty

assert property (p_wdata_stable_setup_to_access)
  else $error("APB ERROR: PWDATA changed from SETUP to ACCESS");
  
// TEMPORAL ASSERTION : ACCESS MUST FOLLOW SETUP  assertion 7
// USING $past()

// property p_access_has_previous_setup;
//     @(posedge PCLK)
//     disable iff (!PRESETn)
//     (PSEL && PENABLE) |-> $past(PSEL && !PENABLE);
// endproperty

// assert property (p_access_has_previous_setup)
//     else $error("APB ERROR: ACCESS did not have SETUP in previous cycle");
  
/////////////////////////// ASSERTION #7 : PSEL RISING -> SETUP PHASE using $rose

////////////////////////////checking psel high without penable
  
property p_psel_rise_starts_setup;
    @(posedge PCLK)
    disable iff (!PRESETn)
    $rose(PSEL) |-> !PENABLE;
endproperty

assert property (p_psel_rise_starts_setup)
    else $error("APB ERROR: PSEL rose but PENABLE was already HIGH");

  
  ////////////////////////// ASSERTION #8 : PSEL FALL -> PENABLE LOW using $fell
/// when psel fell then  peneble should be  low 
  /////$rose(PSEL) → detect 0 → 1  7th assertion
  /////$fell(PSEL) → detect 1 → 0  8th assertion
  
  

property p_psel_fall_ends_transfer;
    @(posedge PCLK)
    disable iff (!PRESETn)
    $fell(PSEL) |-> !PENABLE;
endproperty

assert property (p_psel_fall_ends_transfer)
    else $error("APB ERROR: PSEL fell while PENABLE is HIGH");
  
  
////////////////////////////////////// ASSERTION #9 
  ///Current PADDR must match its value at the previous assertion sampling point.
  
 property p_paddr_previous_access_stable;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE && $past(PSEL && PENABLE))
    |-> (PADDR == $past(PADDR));
endproperty

assert property (p_paddr_previous_access_stable)
    else $error("APB ERROR: PADDR changed from previous cycle");
  
 
  /////////////////////////////////////ASSERTION 10 
  
  // checking for the Once ACCESS starts, PENABLE must remain HIGH for 1–3 sampled cycles.
  
  property p_penable_stays_high;
    @(posedge PCLK)
    disable iff (!PRESETn)
    PENABLE |-> PENABLE[*1:3];
endproperty

assert property (p_penable_stays_high)
    else $error("APB ERROR: PENABLE did not remain HIGH");

  
  
  
  //////////////////////////////// ASSERTION 11 ---sequence
  
//////////////////check for the Creates a reusable named temporal pattern representing SETUP followed by ACCESS.
//   sequence apb_access_sequence;
//     (PSEL && !PENABLE) ##1
//     (PSEL && PENABLE);
// endsequence

// property p_valid_apb_sequence;
//     @(posedge PCLK)
//     disable iff (!PRESETn)
//     apb_access_sequence;
// endproperty

// assert property (p_valid_apb_sequence)
//     else $error("APB ERROR: Invalid SETUP to ACCESS sequence");
  
  
  /////////////////////////////////ASSERTION 12 
 //// READY must occur 1–3 cycles after ACCESS.
  property p_ready_within_three_cycles;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE) |-> ##[1:3] PREADY;
endproperty

assert property (p_ready_within_three_cycles)
    else $error("APB ERROR: PREADY not received within 3 cycles");
  
  
  ////////////////////////////////ASSERTION 13
  ///READY must occur 1–3 cycles after ACCESS.
  
  property p_reset_outputs;
    @(posedge PCLK)
    !PRESETn |-> (!PREADY && !PSLVERR);
endproperty

assert property (p_reset_outputs)
    else $error("APB ERROR: Output active during reset");
  
  
  
  ////////////////////////////////ASSERTION 14
  //Read-only region must generate error on write   --->  A write to address 0–99 must generate PSLVERR.
  
  
  property p_read_only_write_error;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE && PWRITE && (PADDR <= 32'd99))
    |=> PSLVERR;
endproperty

assert property (p_read_only_write_error)
    else $error("APB ERROR: Write to read-only address without PSLVERR");
  
    ////////////////////////////////ASSERTION 15
  // Write-only region must generate error on read --->A read from address 100–199 must generate PSLVERR.
  
  property p_write_only_read_error;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE && !PWRITE &&
     (PADDR >= 32'd100) && (PADDR <= 32'd199))
    |=> PSLVERR;
endproperty

assert property (p_write_only_read_error)
    else $error("APB ERROR: Read from write-only address without PSLVERR");

  
  ////////////////////////ASSERTION 16 
  ///////////Addresses above 255 must generate an error.
  
  property p_invalid_address_error;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE && (PADDR > 32'd255))
    |=> PSLVERR;
endproperty

assert property (p_invalid_address_error)
    else $error("APB ERROR: Invalid address without PSLVERR");
  
  //////////////////ASSERTION17
  //Valid read regions should not generate PSLVERR.
  property p_valid_read_no_error;
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE && !PWRITE &&
     ((PADDR <= 32'd99) ||
      (PADDR >= 32'd200 && PADDR <= 32'd255)))
    |=> !PSLVERR;
endproperty

assert property (p_valid_read_no_error)
    else $error("APB ERROR: Valid read generated PSLVERR");
  
  
  ///////////////////ASSERTION 18
  //Records coverage when a complete APB write reaches ACCESS.
  
  cover property (
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && !PENABLE && PWRITE)
    ##1
    (PSEL && PENABLE && PWRITE)
);
    
    /////////////////ASSERTION 19
    ///Records coverage when a complete APB read reaches ACCESS.
    
    cover property (
    @(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && !PENABLE && !PWRITE)
    ##1
    (PSEL && PENABLE && !PWRITE)
);
  
  
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
end
endmodule
  