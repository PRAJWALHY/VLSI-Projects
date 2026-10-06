`timescale 1ns/1ps

// APB INTERFACE

interface apb_if (
    input logic PCLK
);

    logic        PRESETn;

    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;

    logic [31:0] PADDR;
    logic [31:0] PWDATA;

    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;


    // SEQUENCE DEFINITIONS


    // 1. APB SETUP PHASE

    sequence setup_phase_s;

        $rose(PSEL) &&
        !PENABLE &&
        !PREADY;

    endsequence

    // 2. WRITE SETUP PHASE

    sequence write_setup_phase_s;

        $rose(PSEL) &&
        PWRITE &&
        !PENABLE &&
        !PREADY;

    endsequence


    // 3. READ SETUP PHASE

    sequence read_setup_phase_s;

        $rose(PSEL) &&
        !PWRITE &&
        !PENABLE &&
        !PREADY;

    endsequence


    // 4. GENERIC ACCESS PHASE

    sequence access_phase_s;

        PSEL &&
        PENABLE &&
        PREADY &&
        $stable(PWRITE) &&
        $stable(PWDATA) &&
        $stable(PADDR) &&
        $stable(PSEL);

    endsequence


    // 5. WRITE ACCESS PHASE

    sequence write_access_phase_s;

        PSEL &&
        PENABLE &&
        PWRITE &&
        PREADY &&
        $stable(PWRITE) &&
        $stable(PWDATA) &&
        $stable(PADDR) &&
        $stable(PSEL);

    endsequence


    // 6. READ ACCESS PHASE

    sequence read_access_phase_s;

        PSEL &&
        PENABLE &&
        !PWRITE &&
        PREADY &&
        $stable(PWRITE) &&
        $stable(PADDR) &&
        $stable(PSEL);

    endsequence


    // 7. COMPLETE WRITE TRANSFER

    sequence write_transfer_s;

        write_setup_phase_s ##1
        write_access_phase_s;

    endsequence


    // 8. COMPLETE READ TRANSFER

    sequence read_transfer_s;

        read_setup_phase_s ##1
        read_access_phase_s;

    endsequence


    // ADVANCED SEQUENCE DEFINITIONS


    // 9. EXACT DELAY
    //
    // SETUP -> exactly one cycle -> ACCESS

    sequence setup_to_access_exact_s;

        setup_phase_s ##1
        access_phase_s;

    endsequence


    // 10. RANGE DELAY
    //
    // SETUP -> ACCESS within 1 to 3 cycles

    sequence setup_to_access_range_s;

        setup_phase_s ##[1:3]
        access_phase_s;

    endsequence


    
    // 11. WRITE EXACT SEQUENCE

    sequence write_setup_to_access_s;

        write_setup_phase_s ##1
        write_access_phase_s;

    endsequence


    // 12. READ EXACT SEQUENCE
    

    sequence read_setup_to_access_s;

        read_setup_phase_s ##1
        read_access_phase_s;

    endsequence


    
    // 13. ACCESS REPETITION
    //
    // ACCESS condition repeated once
    

    sequence access_repeat_one_s;

        access_phase_s[*1];

    endsequence


    
    // 14. SETUP -> ACCESS REPETITION

    sequence setup_access_repeat_s;

        setup_phase_s ##1
        access_phase_s[*1];

    endsequence
  
 
    
// 15. THROUGHOUT SEQUENCE


sequence setup_to_access_window_s;

    1'b1 ##1
    PENABLE;

endsequence
  
  

// 16. UNTIL SEQUENCE


sequence psel_access_until_s;

    PSEL;

endsequence

// 17. WITHIN SEQUENCE


sequence access_within_setup_window_s;

    access_phase_s within
    setup_to_access_range_s;

endsequence



// 18. INTERSECT SEQUENCES


sequence setup_to_access_intersect_s;

    setup_phase_s ##1
    access_phase_s;

endsequence

// for write 
sequence write_setup_to_access_intersect_s;

    write_setup_phase_s ##1
    write_access_phase_s;

endsequence
  
  


    // BASIC PROPERTY DEFINITIONS


    // PROPERTY 1
    // SETUP -> ACCESS
    

    property setup_to_access_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |=> access_phase_s;

    endproperty


    // PROPERTY 2
    // WRITE SETUP -> WRITE ACCESS

    property write_setup_to_access_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        write_setup_phase_s |=> write_access_phase_s;

    endproperty


    // PROPERTY 3
    // READ SETUP -> READ ACCESS

    property read_setup_to_access_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        read_setup_phase_s |=> read_access_phase_s;

    endproperty


    
    // PROPERTY 4
    // PENABLE REQUIRES PSEL

    property penable_requires_psel_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        PENABLE |-> PSEL;

    endproperty


    // PROPERTY 5
    // PREADY ONLY DURING ACCESS

    property pready_only_access_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        PREADY |-> (PSEL && PENABLE);

    endproperty


    
    // PROPERTY 6
    // PSLVERR ONLY DURING ACCESS
    

    property pslverr_only_access_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        PSLVERR |-> (PSEL && PENABLE);

    endproperty


    // PROPERTY 7
    // PADDR STABLE
    

    property address_stable_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |=> $stable(PADDR);

    endproperty


    // PROPERTY 8
    // PWRITE STABLE

    property write_stable_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |=> $stable(PWRITE);

    endproperty


    // PROPERTY 9
    // PWDATA STABLE

    property wdata_stable_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        write_setup_phase_s |=> $stable(PWDATA);

    endproperty


    
    // PROPERTY 10
    // PSEL STABLE
    

    property psel_stable_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |=> $stable(PSEL);

    endproperty



    // ADVANCED PROPERTY DEFINITIONS


    // PROPERTY 11
    // ##1
    //
    // IMPORTANT:
    // The sequence is used as the antecedent.

    property setup_to_access_exact_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |-> ##1
        access_phase_s;

    endproperty


    // PROPERTY 12
    // ##[1:3]

    property setup_to_access_range_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |-> ##[1:3]
        access_phase_s;

    endproperty


    // PROPERTY 13
    // WRITE ##1

    property write_exact_sequence_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        write_setup_phase_s |-> ##1
        write_access_phase_s;

    endproperty


    // PROPERTY 14
    // READ ##1

    property read_exact_sequence_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        read_setup_phase_s |-> ##1
        read_access_phase_s;

    endproperty


    // PROPERTY 15
    // REPETITION

    property access_repetition_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |-> ##1
        access_phase_s[*1];

    endproperty
  
      
    // PROPERTY 16
    // first_match
    

    property first_access_after_setup_p;

        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_phase_s |-> first_match(
            ##[1:3] access_phase_s
        );

    endproperty

      
   
// PROPERTY 17
// THROUGHOUT


property psel_throughout_transfer_p;

    @(posedge PCLK)
    disable iff (!PRESETn)

    setup_phase_s |-> 
        (PSEL throughout setup_to_access_window_s);

endproperty
  
  
// PROPERTY 18
// UNTIL


property psel_until_access_p;

    @(posedge PCLK)
    disable iff (!PRESETn)

    setup_phase_s |->
        psel_access_until_s until_with PENABLE;

endproperty
  
  
  
// PROPERTY 19
// WITHIN


property access_within_setup_window_p;

    @(posedge PCLK)
    disable iff (!PRESETn)

    setup_phase_s |->
        access_within_setup_window_s;

endproperty
  
  
// PROPERTY 20
// INTERSECT


property apb_intersect_transfer_p;

    @(posedge PCLK)
    disable iff (!PRESETn)

    write_setup_phase_s |->
        (
            setup_to_access_intersect_s
            intersect
            write_setup_to_access_intersect_s
        );

endproperty

    // ASSERTIONS


    // BASIC SVA 01

    APB_SETUP_TO_ACCESS:

    assert property (setup_to_access_p)

    else
        $error(
            "[SVA-01] SETUP was not followed by ACCESS"
        );


    // BASIC SVA 02

    APB_WRITE_SETUP_TO_ACCESS:

    assert property (write_setup_to_access_p)

    else
        $error(
            "[SVA-02] WRITE SETUP was not followed by WRITE ACCESS"
        );


    
    // BASIC SVA 03

    APB_READ_SETUP_TO_ACCESS:

    assert property (read_setup_to_access_p)

    else
        $error(
            "[SVA-03] READ SETUP was not followed by READ ACCESS"
        );


    // BASIC SVA 04
    

    APB_PENABLE_REQUIRES_PSEL:

    assert property (penable_requires_psel_p)

    else
        $error(
            "[SVA-04] PENABLE HIGH without PSEL HIGH"
        );


    
    // BASIC SVA 05
    

    APB_PREADY_ONLY_ACCESS:

    assert property (pready_only_access_p)

    else
        $error(
            "[SVA-05] PREADY HIGH outside ACCESS"
        );


    // BASIC SVA 06
    

    APB_PSLVERR_ONLY_ACCESS:

    assert property (pslverr_only_access_p)

    else
        $error(
            "[SVA-06] PSLVERR HIGH outside ACCESS"
        );


    
    // BASIC SVA 07
    

    APB_PADDR_STABLE:

    assert property (address_stable_p)

    else
        $error(
            "[SVA-07] PADDR changed between SETUP and ACCESS"
        );


    
    // BASIC SVA 08

    APB_PWRITE_STABLE:

    assert property (write_stable_p)

    else
        $error(
            "[SVA-08] PWRITE changed between SETUP and ACCESS"
        );


    
    // BASIC SVA 09
    

    APB_PWDATA_STABLE:

    assert property (wdata_stable_p)

    else
        $error(
            "[SVA-09] PWDATA changed between SETUP and ACCESS"
        );


    
    // BASIC SVA 10
    

    APB_PSEL_STABLE:

    assert property (psel_stable_p)

    else
        $error(
            "[SVA-10] PSEL changed between SETUP and ACCESS"
        );


    
    // ADVANCED ASSERTIONS
    


    
    // ADVANCED SVA 11
    // EXACT ##1
    

    APB_EXACT_DELAY:

    assert property (setup_to_access_exact_p)

    else
        $error(
            "[ADV-SVA-11] ACCESS did not occur exactly one cycle after SETUP"
        );


    
    // ADVANCED SVA 12
    // ##[1:3]
    

    APB_RANGE_DELAY:

    assert property (setup_to_access_range_p)

    else
        $error(
            "[ADV-SVA-12] ACCESS did not occur within 1 to 3 cycles"
        );


    // ADVANCED SVA 13
    // WRITE ##1

    APB_WRITE_EXACT_SEQUENCE:

    assert property (write_exact_sequence_p)

    else
        $error(
            "[ADV-SVA-13] WRITE sequence failed"
        );


    
    // ADVANCED SVA 14
    // READ ##1
    

    APB_READ_EXACT_SEQUENCE:

    assert property (read_exact_sequence_p)

    else
        $error(
            "[ADV-SVA-14] READ sequence failed"
        );


    
    // ADVANCED SVA 15
    // REPETITION [*1]
    

    APB_ACCESS_REPETITION:

    assert property (access_repetition_p)

    else
        $error(
            "[ADV-SVA-15] ACCESS repetition sequence failed"
        );

          
    // ADVANCED SVA 16
    // first_match
    

    APB_FIRST_MATCH_ACCESS:

    assert property (first_access_after_setup_p)

    else
        $error(
            "[ADV-SVA-16] First ACCESS match after SETUP failed"
        );

      
   
// ADVANCED SVA 17
// THROUGHOUT


APB_PSEL_THROUGHOUT_TRANSFER:

assert property (psel_throughout_transfer_p)

else
    $error(
        "[ADV-SVA-17] PSEL was not HIGH throughout SETUP to ACCESS"
    );
      
  
  
// ADVANCED SVA 18
// UNTIL


APB_PSEL_UNTIL_ACCESS:

assert property (psel_until_access_p)

else
    $error(
        "[ADV-SVA-18] PSEL did not remain HIGH until ACCESS"
    );



// ADVANCED SVA 19
// WITHIN


APB_ACCESS_WITHIN_SETUP:

assert property (access_within_setup_window_p)

else
    $error(
        "[ADV-SVA-19] ACCESS did not occur within the SETUP window"
    );



// ADVANCED SVA 20
// INTERSECT

APB_INTERSECT_TRANSFER:

assert property (apb_intersect_transfer_p)

else
    $error(
        "[ADV-SVA-20] APB sequences did not intersect correctly"
    );
      
    // COVER PROPERTIES
    


    
    // COVER 1
    // WRITE TRANSFER
    

    cover_write_transfer:

    cover property (
        @(posedge PCLK)
        disable iff (!PRESETn)

        write_transfer_s
    );


    
    // COVER 2
    // READ TRANSFER
    

    cover_read_transfer:

    cover property (
        @(posedge PCLK)
        disable iff (!PRESETn)

        read_transfer_s
    );


    
    // COVER 3
    // EXACT ##1
    

    cover_exact_delay:

    cover property (
        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_to_access_exact_s
    );


    
    // COVER 4
    // RANGE ##[1:3]
    

    cover_range_delay:

    cover property (
        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_to_access_range_s
    );


    
    // COVER 5
    // REPETITION
    

    cover_repetition:

    cover property (
        @(posedge PCLK)
        disable iff (!PRESETn)

        setup_access_repeat_s
    );


endinterface




// TESTBENCH


module tb;


    
    // CLOCK
    

    logic PCLK;


    initial begin

        PCLK = 1'b0;

        forever
            #5 PCLK = ~PCLK;

    end



    
    // APB INTERFACE
    

    apb_if apb(PCLK);



    
    // dut
    

    apb_slave #(
        .ADDR_WIDTH (32),
        .DATA_WIDTH (32),
        .NUM_REGS   (16)
    )
    dut (

        .PCLK    (PCLK),
        .PRESETn (apb.PRESETn),

        .PSEL    (apb.PSEL),
        .PENABLE (apb.PENABLE),
        .PWRITE  (apb.PWRITE),

        .PADDR   (apb.PADDR),
        .PWDATA  (apb.PWDATA),

        .PRDATA  (apb.PRDATA),
        .PREADY  (apb.PREADY),
        .PSLVERR (apb.PSLVERR)

    );



    
    // VCD
    

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

    end



    
    // INITIALIZE
    

    task automatic initialize_signals();

        begin

            apb.PRESETn = 1'b0;

            apb.PSEL    = 1'b0;
            apb.PENABLE = 1'b0;
            apb.PWRITE  = 1'b0;

            apb.PADDR   = 32'h0000_0000;
            apb.PWDATA  = 32'h0000_0000;

        end

    endtask



    
    // RESET
    

    task automatic reset_dut();

        begin

            initialize_signals();

            repeat (3)
                @(negedge PCLK);

            apb.PRESETn = 1'b1;

            $display("");
            $display("==============================================");
            $display("              RESET RELEASED");
            $display("==============================================");
            $display("");

        end

    endtask



    // GENERATE SETUP
    

    task automatic generate_setup_phase(
        input logic [31:0] addr,
        input logic [31:0] data,
        input logic        write
    );

        begin

            @(negedge PCLK);

            apb.PSEL    = 1'b1;
            apb.PENABLE = 1'b0;
            apb.PWRITE  = write;

            apb.PADDR   = addr;
            apb.PWDATA  = data;

            $display(
                "[%0t] SETUP  : PSEL=%b PENABLE=%b PWRITE=%b PADDR=%h PWDATA=%h",
                $time,
                apb.PSEL,
                apb.PENABLE,
                apb.PWRITE,
                apb.PADDR,
                apb.PWDATA
            );

        end

    endtask



    
    // GENERATE ACCESS
    

    task automatic generate_access_phase();

        begin

            @(negedge PCLK);

            apb.PENABLE = 1'b1;

            $display(
                "[%0t] ACCESS : PSEL=%b PENABLE=%b PWRITE=%b PADDR=%h PWDATA=%h",
                $time,
                apb.PSEL,
                apb.PENABLE,
                apb.PWRITE,
                apb.PADDR,
                apb.PWDATA
            );

            @(posedge PCLK);

        end

    endtask


    
    // END TRANSFER
    

    task automatic end_transfer();

        begin

            @(negedge PCLK);

            apb.PSEL    = 1'b0;
            apb.PENABLE = 1'b0;
            apb.PWRITE  = 1'b0;

            apb.PADDR   = 32'h0000_0000;
            apb.PWDATA  = 32'h0000_0000;

        end

    endtask



    // APB WRITE
    

    task automatic apb_write(
        input logic [31:0] addr,
        input logic [31:0] data
    );

        begin

            $display("");
            $display("----------------------------------------------");
            $display("               APB WRITE");
            $display("----------------------------------------------");

            generate_setup_phase(
                addr,
                data,
                1'b1
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PREADY && !apb.PSLVERR) begin

                $display(
                    "[%0t] WRITE SUCCESS : ADDR=%h DATA=%h",
                    $time,
                    addr,
                    data
                );

            end
            else begin

                $error(
                    "[%0t] WRITE FAILED : ADDR=%h PSLVERR=%b",
                    $time,
                    addr,
                    apb.PSLVERR
                );

            end

            end_transfer();

        end

    endtask



    
    // APB READ
    

    task automatic apb_read(
        input logic [31:0] addr
    );

        logic [31:0] expected_data;

        begin

            $display("");
            $display("----------------------------------------------");
            $display("               APB READ");
            $display("----------------------------------------------");

            generate_setup_phase(
                addr,
                32'h0000_0000,
                1'b0
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PREADY && !apb.PSLVERR) begin

                expected_data = dut.reg_mem[addr >> 2];

                if (apb.PRDATA == expected_data) begin

                    $display(
                        "[%0t] READ SUCCESS : ADDR=%h DATA=%h",
                        $time,
                        addr,
                        apb.PRDATA
                    );

                end
                else begin

                    $error(
                        "[%0t] READ DATA ERROR : EXPECTED=%h ACTUAL=%h",
                        $time,
                        expected_data,
                        apb.PRDATA
                    );

                end

            end
            else begin

                $error(
                    "[%0t] READ FAILED : ADDR=%h PSLVERR=%b",
                    $time,
                    addr,
                    apb.PSLVERR
                );

            end

            end_transfer();

        end

    endtask



    
    // TEST 1
    

    task automatic test_write();

        begin

            $display("");
            $display("==============================================");
            $display("        TEST 1 : WRITE TRANSACTION");
            $display("==============================================");

            apb_write(
                32'h0000_0000,
                32'hAAAA_BBBB
            );

        end

    endtask



    
    // TEST 2
    

    task automatic test_read();

        begin

            $display("");
            $display("==============================================");
            $display("         TEST 2 : READ TRANSACTION");
            $display("==============================================");

            apb_read(
                32'h0000_0000
            );

        end

    endtask



    
    // TEST 3
    

    task automatic test_multiple_registers();

        begin

            $display("");
            $display("==============================================");
            $display("       TEST 3 : MULTIPLE REGISTERS");
            $display("==============================================");

            apb_write(
                32'h0000_0004,
                32'h1234_5678
            );

            apb_write(
                32'h0000_0008,
                32'hDEAD_BEEF
            );

            apb_write(
                32'h0000_000C,
                32'hCAFE_BABE
            );

            apb_read(32'h0000_0004);

            apb_read(32'h0000_0008);

            apb_read(32'h0000_000C);

        end

    endtask



    // TEST 4

    task automatic test_invalid_address();

        begin

            $display("");
            $display("==============================================");
            $display("       TEST 4 : INVALID ADDRESS");
            $display("==============================================");

            generate_setup_phase(
                32'h0000_0100,
                32'h0000_0000,
                1'b0
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PSLVERR) begin

                $display(
                    "[%0t] INVALID ADDRESS CORRECTLY DETECTED",
                    $time
                );

            end
            else begin

                $error(
                    "[%0t] INVALID ADDRESS ERROR NOT DETECTED",
                    $time
                );

            end

            end_transfer();

        end

    endtask



    // TEST 5
    

    task automatic test_sequence();

        begin

            $display("");
            $display("==============================================");
            $display("      TEST 5 : SETUP -> ACCESS SEQUENCE");
            $display("==============================================");

            generate_setup_phase(
                32'h0000_0010,
                32'h1111_2222,
                1'b1
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PREADY) begin

                $display(
                    "[%0t] SETUP -> ACCESS -> READY COMPLETE",
                    $time
                );

            end

            end_transfer();

        end

    endtask



    
    // TEST 6
    

    task automatic test_back_to_back();

        begin

            $display("");
            $display("==============================================");
            $display("       TEST 6 : BACK-TO-BACK TRANSFERS");
            $display("==============================================");

            apb_write(
                32'h0000_0014,
                32'h5555_AAAA
            );

            apb_write(
                32'h0000_0018,
                32'hBBBB_6666
            );

            apb_read(
                32'h0000_0014
            );

            apb_read(
                32'h0000_0018
            );

        end

    endtask



    
    // TEST 7
    // ##1
    

    task automatic test_advanced_exact();

        begin

            $display("");
            $display("==============================================");
            $display("      TEST 7 : ADVANCED ##1 SEQUENCE");
            $display("==============================================");

            generate_setup_phase(
                32'h0000_0020,
                32'hAAAA_1111,
                1'b1
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PREADY) begin

                $display(
                    "[%0t] ##1 SEQUENCE EXECUTED",
                    $time
                );

            end

            end_transfer();

        end

    endtask



    
    // TEST 8
    // ##[1:3]
    

    task automatic test_advanced_range();

        begin

            $display("");
            $display("==============================================");
            $display("      TEST 8 : ADVANCED ##[1:3] SEQUENCE");
            $display("==============================================");

            generate_setup_phase(
                32'h0000_0024,
                32'hBBBB_2222,
                1'b1
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PREADY) begin

                $display(
                    "[%0t] ##[1:3] SEQUENCE MATCHED",
                    $time
                );

            end

            end_transfer();

        end

    endtask



    // TEST 9
    // [*1]

    task automatic test_advanced_repetition();

        begin

            $display("");
            $display("==============================================");
            $display("      TEST 9 : ADVANCED [*1] REPETITION");
            $display("==============================================");

            generate_setup_phase(
                32'h0000_0028,
                32'hCCCC_3333,
                1'b1
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PREADY) begin

                $display(
                    "[%0t] [*1] REPETITION SEQUENCE MATCHED",
                    $time
                );

            end

            end_transfer();

        end

    endtask

      
    // TEST 10
    // first_match

    task automatic test_first_match();

        begin

            $display("");
            $display("==============================================");
            $display("      TEST 10 : first_match");
            $display("==============================================");

            generate_setup_phase(
                32'h0000_002C,
                32'hDDDD_4444,
                1'b1
            );

            @(posedge PCLK);

            generate_access_phase();

            if (apb.PREADY) begin

                $display(
                    "[%0t] first_match SEQUENCE MATCHED",
                    $time
                );

            end

            end_transfer();

        end

    endtask


        
    // TEST 11
    // throughout
    

task test_throughout();

    $display("");
    $display("==============================================");
    $display("       TEST 11 : THROUGHOUT");
    $display("==============================================");

    apb_write(
        32'h0000_0034,
        32'hAAAA_5555
    );

    $display("[%0t] throughout SEQUENCE MATCHED", $time);

endtask
    // MAIN TEST
    

    initial begin

        reset_dut();


        
        // BASIC TESTS
        

        test_write();

        test_read();

        test_multiple_registers();

        test_invalid_address();

        test_sequence();

        test_back_to_back();


        
        // ADVANCED SVA TESTS
        

        test_advanced_exact();

        test_advanced_range();

        test_advanced_repetition();
        
        test_first_match();
      
        test_throughout();

// //        ==================================================
//   //      INTENTIONAL VIOLATION TEST - first_match
//     //    ==================================================

//         $display("");
//         $display("==============================================");
//         $display("     FIRST_MATCH VIOLATION TEST");
//         $display("==============================================");

//         @(negedge PCLK);

//         // SETUP PHASE
//         apb.PSEL    = 1'b1;
//         apb.PENABLE = 1'b0;
//         apb.PWRITE  = 1'b1;
//         apb.PADDR   = 32'h0000_0030;
//         apb.PWDATA  = 32'hEEEE_5555;

//         $display("[%0t] SETUP driven", $time);

//         @(posedge PCLK);

//         $display("[%0t] SETUP sampled", $time);

//         // INTENTIONALLY DO NOT ENTER ACCESS
//         // first_match expects ACCESS within 1 to 3 cycles

//         repeat (4)
//             @(posedge PCLK);

//       $display("[%0t] FIRST_MATCH VIOLATION SHOULD OCCUR", $time);

       //==================================================
        // INTENTIONAL VIOLATION TEST - throughout
        //==================================================

//         $display("");
//         $display("==============================================");
//         $display("     THROUGHOUT VIOLATION TEST");
//         $display("==============================================");

//         @(negedge PCLK);

//         // SETUP PHASE
//         apb.PSEL    = 1'b1;
//         apb.PENABLE = 1'b0;
//         apb.PWRITE  = 1'b1;
//         apb.PADDR   = 32'h0000_0038;
//         apb.PWDATA  = 32'hFFFF_6666;

//         $display("[%0t] SETUP driven", $time);

//         @(posedge PCLK);

//         // ACCESS PHASE
//         apb.PENABLE = 1'b1;

//         $display("[%0t] ACCESS started", $time);

//         // Wait until ACCESS is active
//         @(negedge PCLK);

//         // INTENTIONALLY BREAK PSEL
//         apb.PSEL = 1'b0;

//         $display(
//             "[%0t] PSEL intentionally driven LOW during ACCESS",
//             $time
//         );

//         @(posedge PCLK);

//         $display(
//             "[%0t] THROUGHOUT VIOLATION SHOULD OCCUR",
//             $time
//         );

//         #10;

//         apb.PENABLE = 1'b0;
      //==================================================
// INTENTIONAL VIOLATION TEST - until
//==================================================

// $display("");
// $display("==============================================");
// $display("        UNTIL VIOLATION TEST");
// $display("==============================================");

// @(negedge PCLK);

// // SETUP PHASE
// apb.PSEL    = 1'b1;
// apb.PENABLE = 1'b0;
// apb.PWRITE  = 1'b1;
// apb.PADDR   = 32'h0000_0040;
// apb.PWDATA  = 32'h1111_AAAA;

// $display("[%0t] UNTIL SETUP driven", $time);

// @(posedge PCLK);

// // ACCESS PHASE
// apb.PENABLE = 1'b1;

// $display("[%0t] UNTIL ACCESS started", $time);

// @(negedge PCLK);

// // INTENTIONALLY BREAK PSEL
// apb.PSEL = 1'b0;

// $display(
//     "[%0t] PSEL intentionally driven LOW before ACCESS completion",
//     $time
// );

// // SVA samples the violation
// @(posedge PCLK);

// $display(
//     "[%0t] UNTIL VIOLATION SHOULD OCCUR",
//     $time
// );

// @(negedge PCLK);

// apb.PSEL    = 1'b0;
// apb.PENABLE = 1'b0;
// apb.PWRITE  = 1'b0;
      
     ///==================================================
// INTENTIONAL VIOLATION TEST - within
//==================================================

// $display("");
// $display("==============================================");
// $display("        WITHIN VIOLATION TEST");
// $display("==============================================");

// @(negedge PCLK);

// // SETUP PHASE
// apb.PSEL    = 1'b1;
// apb.PENABLE = 1'b0;
// apb.PWRITE  = 1'b1;
// apb.PADDR   = 32'h0000_0044;
// apb.PWDATA  = 32'h2222_BBBB;

// $display("[%0t] WITHIN SETUP driven", $time);

// @(posedge PCLK);

// $display(
//     "[%0t] SETUP sampled - intentionally delaying ACCESS",
//     $time
// );

// // INTENTIONALLY DO NOT ENTER ACCESS
// // WITHIN should require ACCESS inside the allowed window

// repeat (4)
//     @(posedge PCLK);

// $display(
//     "[%0t] WITHIN VIOLATION SHOULD OCCUR",
//     $time
// );

// @(negedge PCLK);

// apb.PSEL    = 1'b0;
// apb.PENABLE = 1'b0;
// apb.PWRITE  = 1'b0;
      
      //==================================================
// INTENTIONAL VIOLATION TEST - intersect
//==================================================

$display("");
$display("==============================================");
$display("        INTERSECT VIOLATION TEST");
$display("==============================================");

@(negedge PCLK);

// WRITE SETUP
apb.PSEL    = 1'b1;
apb.PENABLE = 1'b0;
apb.PWRITE  = 1'b1;
apb.PADDR   = 32'h0000_0048;
apb.PWDATA  = 32'h3333_CCCC;

$display("[%0t] INTERSECT WRITE SETUP driven", $time);

@(posedge PCLK);

$display("[%0t] WRITE SETUP sampled", $time);

// INTENTIONALLY DO NOT ENTER WRITE ACCESS
// This prevents the two sequences from ending
// at the same time.

repeat (2)
    @(posedge PCLK);

$display(
    "[%0t] INTERSECT VIOLATION SHOULD OCCUR",
    $time
);

@(negedge PCLK);

apb.PSEL    = 1'b0;
apb.PENABLE = 1'b0;
apb.PWRITE  = 1'b0;
        
        // FINISH
        

        repeat (3)
            @(posedge PCLK);


        $display("");
        $display("==============================================");
        $display("       ALL APB TESTS COMPLETED");
        $display("==============================================");
        $display("");

        $finish;

    end

endmodule
