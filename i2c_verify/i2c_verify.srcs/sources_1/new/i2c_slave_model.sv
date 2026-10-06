module i2c_slave_model (i2c_if.SLAVE vif);

    // --- Slave Registers and Configuration ---
    reg [7:0]   slave_data_reg [255:0]; 
    reg [6:0]   my_addr = 7'h50;        
    reg         in_transaction;         
    reg [7:0]   byte_recv;              
    reg [3:0]   bit_count;              
    reg [7:0]   reg_ptr;                
    reg         slave_ack;              
    reg         scl_prev;               
    
    reg         reg_ptr_initialized = 1'b0; 
    
    // FIX: Global declaration of loop variable as integer for maximum compatibility
    integer i;

    // --- State Machine Definitions ---
    localparam S_IDLE        = 3'h0;
    localparam S_ADDR_RECV   = 3'h1; 
    localparam S_DATA_RECV   = 3'h2; 
    localparam S_DATA_SEND   = 3'h3; 
    localparam S_ACK_SEND    = 3'h4; 
    localparam S_ACK_RECV    = 3'h5; 

    reg [2:0] slave_state;

    // FIX: Memory initialization in a separate INITIAL block.
    initial begin
        for (i = 0; i < 256; i = i + 1) begin 
            slave_data_reg[i] = 8'hAA; 
        end
    end

    // --- Procedural Logic ---
    // ... (rest of the always block logic, which is now syntactically correct) ...
    always @(posedge vif.clk or negedge vif.rst_n) begin
        if (!vif.rst_n) begin
            scl_prev <= 1'b0;
            slave_state <= S_IDLE;
            in_transaction <= 1'b0;
            vif.sda_t <= 1'b1; 
            vif.sda_o <= 1'b0;
            reg_ptr <= 8'h00;
            reg_ptr_initialized <= 1'b0; 
        end else begin
            scl_prev <= vif.scl;
            
            // 1. START/STOP Condition Detection
            // Start Condition: SCL=1, SDA falling edge
            if (vif.scl && scl_prev && !vif.sda && vif.sda) begin
                in_transaction <= 1'b1;
                slave_state <= S_ADDR_RECV;
                bit_count <= 7;
                byte_recv <= 0;
            end
            
            // Stop Condition: SCL=1, SDA rising edge
            if (vif.scl && scl_prev && vif.sda && !vif.sda) begin
                in_transaction <= 1'b0;
                slave_state <= S_IDLE;
                vif.sda_t <= 1'b1; 
            end
            
            // 2. Transaction State Machine
            if (in_transaction) begin
                case (slave_state)
                    S_IDLE: begin
                        vif.sda_t <= 1'b1;
                    end
                    
                    S_ADDR_RECV: begin
                        vif.sda_t <= 1'b1; 
                        if (vif.scl && ~scl_prev) begin 
                            byte_recv[bit_count] <= vif.sda; 
                            
                            if (bit_count == 0) begin 
                                if (byte_recv[7:1] == my_addr) begin
                                    slave_ack <= 1'b0; 
                                end else begin
                                    slave_ack <= 1'b1; 
                                end
                                slave_state <= S_ACK_SEND;
                            end else begin
                                bit_count <= bit_count - 1;
                            end
                        end
                    end
                    
                    S_ACK_SEND: begin
                        if (~vif.scl && scl_prev) begin 
                            vif.sda_t <= 1'b0; 
                            vif.sda_o <= slave_ack; 
                        end else if (vif.scl && ~scl_prev) begin 
                            vif.sda_t <= 1'b1; 
                            if (~slave_ack) begin 
                                if (byte_recv[0] == 1'b0) begin 
                                    slave_state <= S_DATA_RECV;
                                end else begin 
                                    slave_state <= S_DATA_SEND;
                                end
                                bit_count <= 7;
                                byte_recv <= 0;
                            end else begin
                                slave_state <= S_IDLE; 
                            end
                        end
                    end
                    
                    S_DATA_RECV: begin 
                        vif.sda_t <= 1'b1; 
                        if (vif.scl && ~scl_prev) begin 
                            byte_recv[bit_count] <= vif.sda; 
                            
                            if (bit_count == 0) begin 
                                
                                if (reg_ptr_initialized == 1'b0) begin 
                                    reg_ptr <= byte_recv; 
                                    reg_ptr_initialized <= 1'b1; 
                                end else begin 
                                    slave_data_reg[reg_ptr] <= byte_recv;
                                    reg_ptr <= reg_ptr + 1; 
                                end
                                
                                slave_ack <= 1'b0; 
                                bit_count <= 7;
                                slave_state <= S_ACK_SEND; 
                            end else begin
                                bit_count <= bit_count - 1;
                            end
                        end
                    end
                    
                    S_DATA_SEND: begin
                        if (~vif.scl && scl_prev) begin 
                            vif.sda_t <= 1'b0; 
                            vif.sda_o <= slave_data_reg[reg_ptr][bit_count]; 
                        end 
                        else if (vif.scl && ~scl_prev) begin 
                            vif.sda_t <= 1'b1; 
                            if (bit_count == 0) begin
                                slave_state <= S_ACK_RECV; 
                            end else begin
                                bit_count <= bit_count - 1;
                            end
                        end
                    end
                    
                    S_ACK_RECV: begin
                        vif.sda_t <= 1'b1; 
                        if (vif.scl && ~scl_prev) begin 
                            if (vif.sda == 1'b0) begin 
                                reg_ptr <= reg_ptr + 1; 
                                bit_count <= 7;
                                slave_state <= S_DATA_SEND;
                            end else begin 
                                slave_state <= S_IDLE; 
                            end
                        end
                    end

                endcase
            end
        end
    end
endmodule