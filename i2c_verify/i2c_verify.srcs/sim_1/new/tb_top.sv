module i2c_master_tb;

    // --- Clock and Reset Signals ---
    reg clk; 
    reg rst_n;
    
    // --- Clock Generator ---
    parameter CLK_PERIOD = 10; 
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // --- I2C Interface Instantiation ---
    i2c_if i2c_bus_if (
        .clk(clk), 
        .rst_n(rst_n)
    );
    
    // --- Master Input/Output TB Signals ---
    reg         tb_cmd_valid;
    reg [6:0]   tb_slave_addr;
    reg         tb_read_write;
    reg [7:0]   tb_data_write;
    wire        tb_cmd_ready;
    wire        tb_i2c_busy;
    wire        tb_ack_error;
    wire [7:0]  tb_data_read;

    // --- DUT Instantiation (I2C Master) ---
    i2c_master DUT (
        .clk            (i2c_bus_if.clk),
        .rst_n          (i2c_bus_if.rst_n),
        .i_cmd_valid    (tb_cmd_valid),
        .i_slave_addr   (tb_slave_addr),
        .i_read_write   (tb_read_write),
        .i_data_write   (tb_data_write),
        .o_cmd_ready    (tb_cmd_ready),
        .o_i2c_busy     (tb_i2c_busy),
        .o_ack_error    (tb_ack_error),
        .o_data_read    (tb_data_read),
        .o_scl          (i2c_bus_if.scl_o),
        .o_sda_o        (i2c_bus_if.sda_o),
        .o_sda_t        (i2c_bus_if.sda_t),
        .i_sda_i        (i2c_bus_if.sda_i)
    );
    
    // --- Slave BFM Instantiation ---
    i2c_slave_model SLAVE_MODEL (.vif (i2c_bus_if));

    // --- Test Stimulus Tasks (Most Conservative Verilog 2001 style) ---
    task wait_for_ready;
        begin // Explicitly wrap task body
            @(posedge clk);
            // FIX: Corrected typo $ime to $time
            $display("Time %0t: Waiting for Master to be ready.", $time); 
            while (!tb_cmd_ready) @(posedge clk);
        end
    endtask

    task send_transaction;
        input [6:0] addr;
        input       rw; 
        input [7:0] data;
        
        begin // Explicitly wrap task body
            @(posedge clk);
            tb_slave_addr = addr;
            tb_read_write = rw;
            tb_data_write = data;
            tb_cmd_valid  = 1'b1;
            @(posedge clk);
            tb_cmd_valid  = 1'b0;
            
            // Wait for transaction to finish
            while (tb_i2c_busy) @(posedge clk);
            
            if (tb_ack_error) $error("Time %0t: Transaction to Slave %h failed (ACK Error).", $time, addr);
        end
    endtask

    // --- Main Test Sequence ---
    initial begin
        // Initialize TB signals
        tb_cmd_valid  = 1'b0;
        tb_slave_addr = 7'h00;
        tb_read_write = 1'b0;
        tb_data_write = 8'h00;
        
        // Reset sequence
        $display("Time %0t: Asserting Reset.", $time);
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        
        $display("Time %0t: Reset complete. Start testing.", $time);
        
        // --- TEST CASE 1: WRITE Reg Address (0x10) ---
        $display("----------------------------------------------");
        $display("Time %0t: Starting WRITE Reg Address (0x10) to Slave 0x50.", $time);
        wait_for_ready;
        send_transaction(7'h50, 1'b0, 8'h10); 
        
        // --- TEST CASE 2: WRITE Data (0x5A) ---
        $display("----------------------------------------------");
        $display("Time %0t: Starting WRITE Data (0x5A) to Reg 0x10.", $time);
        wait_for_ready;
        send_transaction(7'h50, 1'b0, 8'h5A); 
        
        // --- TEST CASE 3: READ Data from Reg 0x10 ---
        $display("----------------------------------------------");
        $display("Time %0t: Starting READ from Reg 0x10.", $time);
        wait_for_ready;
        send_transaction(7'h50, 1'b1, 8'h00); 
        
        // Verification Check
        @(posedge clk);
        if (tb_data_read === 8'h5A) begin
             $display("Time %0t: Verification PASSED ?: Read data 0x%h matches written data 0x%h.", $time, tb_data_read, 8'h5A);
        end else begin
             $error("Time %0t: Verification FAILED ?: Read data 0x%h mismatch. Expected 0x5A.", $time, tb_data_read);
        end
        
        // --- Test Case 4: NACK from Non-Existent Slave ---
        $display("----------------------------------------------");
        $display("Time %0t: Testing NACK (Non-Existent Slave 0x7F).", $time);
        wait_for_ready;
        send_transaction(7'h7F, 1'b0, 8'h00); 
        
        @(posedge clk);
        if (tb_ack_error) $display("Time %0t: NACK Error test PASSED ?. Master detected NACK for Slave 0x7F.", $time);
        else $error("Time %0t: NACK Error test FAILED ?. Master did not detect NACK.", $time);
        
        $finish; 
    end

endmodule