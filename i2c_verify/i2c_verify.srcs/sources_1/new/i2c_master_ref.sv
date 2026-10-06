module i2c_master (
    // System Interface
    input           clk,        
    input           rst_n,      
    
    // Command Interface
    input           i_cmd_valid,    
    input   [6:0]   i_slave_addr,   
    input           i_read_write,   
    input   [7:0]   i_data_write,   
    output  reg     o_cmd_ready,    
    
    // Status Interface
    output  reg     o_i2c_busy,     
    output  reg     o_ack_error,    
    output  reg [7:0] o_data_read,    
    
    // I2C Bus Interface (o_scl is now implicitly a 'wire')
    output          o_scl,          // SCL output to bus (now a wire)
    output  reg     o_sda_o,        
    output  reg     o_sda_t,        
    input           i_sda_i         
);

    // --- Local Parameters and Constants ---
    localparam CLK_FREQ_MHZ  = 100;
    localparam I2C_FREQ_KHZ  = 100;
    // Calculation: (100MHz * 1000) / (100KHz * 2) = 500
    localparam CLKS_PER_BIT  = (CLK_FREQ_MHZ * 1000) / (I2C_FREQ_KHZ * 2); 

    // --- State Machine Definitions ---
    localparam S_IDLE        = 4'h0;
    localparam S_START       = 4'h1;
    localparam S_ADDR        = 4'h2;
    localparam S_ACK_ADDR    = 4'h3;
    localparam S_DATA_WRITE  = 4'h4;
    localparam S_DATA_READ   = 4'h5;
    localparam S_ACK_DATA_W  = 4'h6;
    localparam S_NACK_DATA_R = 4'h7;
    localparam S_STOP        = 4'h8;
    
    // --- Internal Registers and Wires ---
    reg [3:0]   state_reg;
    reg [10:0]  clk_cnt;
    reg [2:0]   bit_cnt;
    reg [7:0]   data_shift_reg;
    reg [7:0]   internal_data_read;

    // --- Clock Generation for I2C SCL ---
    reg scl_int; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= 0;
            scl_int <= 1'b0;
        end else begin
            if (o_i2c_busy) begin 
                if (clk_cnt == CLKS_PER_BIT - 1) begin
                    clk_cnt <= 0;
                    scl_int <= ~scl_int; 
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end else begin
                clk_cnt <= 0;
                scl_int <= 1'b0;
            end
        end
    end

    // --- SCL Output Control ---
    // o_scl_t controls the tri-state buffer (0 = drive, 1 = release/high-Z)
    assign o_scl_t = (scl_int == 1'b0 && o_i2c_busy) ? 1'b0 : 1'b1; 
    // o_scl drives the line low when tri-state is enabled (o_scl_t=0)
    assign o_scl = 1'b0; 

    // --- State Machine and Control Logic ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= S_IDLE;
            o_cmd_ready <= 1'b1;
            o_i2c_busy  <= 1'b0;
            o_ack_error <= 1'b0;
            bit_cnt     <= 0;
            o_data_read <= 8'h00;
            o_sda_t     <= 1'b1; // Release SDA
            o_sda_o     <= 1'b0;
            internal_data_read <= 8'h00;
        end else begin
            
            state_reg <= state_reg; 
            o_cmd_ready <= 1'b0;
            o_ack_error <= o_ack_error; 
            o_data_read <= o_data_read; 

            case (state_reg)
                S_IDLE: begin
                    o_cmd_ready <= 1'b1;
                    o_i2c_busy  <= 1'b0;
                    o_ack_error <= 1'b0;
                    o_data_read <= internal_data_read; 
                    o_sda_t     <= 1'b1; 

                    if (i_cmd_valid) begin
                        data_shift_reg <= {i_slave_addr, i_read_write}; 
                        bit_cnt        <= 7; 
                        state_reg      <= S_START;
                    end
                end

                S_START: begin
                    o_i2c_busy <= 1'b1;
                    
                    // Start Condition: SDA low while SCL is high.
                    o_sda_t <= 1'b1; // Default release SDA
                    o_sda_o <= 1'b0;

                    if (scl_int == 1'b1 && clk_cnt == CLKS_PER_BIT - 2) begin 
                        // Drive SDA low just before SCL goes low
                        o_sda_t    <= 1'b0; 
                        o_sda_o    <= 1'b0;
                    end
                    
                    if (scl_int == 1'b0 && clk_cnt == 0) begin
                        state_reg <= S_ADDR;
                    end
                end

                S_ADDR: begin
                    o_i2c_busy <= 1'b1;
                    o_sda_t <= 1'b0; 
                    o_sda_o <= data_shift_reg[bit_cnt]; 

                    if (clk_cnt == 0 && ~scl_int) begin 
                        if (bit_cnt == 0) begin
                            state_reg <= S_ACK_ADDR;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                S_ACK_ADDR: begin
                    o_i2c_busy <= 1'b1;
                    o_sda_t <= 1'b1; // Release SDA to read ACK/NACK

                    if (clk_cnt == CLKS_PER_BIT/2 && scl_int) begin // Sample ACK
                        if (i_sda_i == 1'b1) begin // NACK received
                            o_ack_error <= 1'b1;
                            state_reg  <= S_STOP;
                        end else begin // ACK received
                            if (data_shift_reg[0] == 1'b0) begin // Master Write
                                data_shift_reg <= i_data_write; 
                                bit_cnt <= 7;
                                state_reg <= S_DATA_WRITE;
                            end else begin // Master Read
                                internal_data_read <= 8'h00; 
                                bit_cnt <= 7;
                                state_reg <= S_DATA_READ;
                            end
                        end
                    end
                end
                
                S_DATA_WRITE: begin
                    o_i2c_busy <= 1'b1;
                    o_sda_t <= 1'b0; 
                    o_sda_o <= data_shift_reg[bit_cnt]; 

                    if (clk_cnt == 0 && ~scl_int) begin 
                        if (bit_cnt == 0) begin
                            state_reg <= S_ACK_DATA_W;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                S_ACK_DATA_W: begin
                    o_i2c_busy <= 1'b1;
                    o_sda_t <= 1'b1; // Release SDA to read ACK/NACK

                    if (clk_cnt == CLKS_PER_BIT/2 && scl_int) begin // Sample ACK
                        if (i_sda_i == 1'b1) begin // NACK received
                            o_ack_error <= 1'b1;
                        end
                        state_reg <= S_STOP; 
                    end
                end
                
                S_DATA_READ: begin
                    o_i2c_busy <= 1'b1;
                    o_sda_t <= 1'b1; // Master must listen (release SDA)
                    
                    if (clk_cnt == CLKS_PER_BIT/2 && scl_int) begin // Sample data
                        internal_data_read[bit_cnt] <= i_sda_i;
                    end else if (clk_cnt == 0 && ~scl_int) begin 
                        if (bit_cnt == 0) begin
                            state_reg <= S_NACK_DATA_R;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                S_NACK_DATA_R: begin
                    o_i2c_busy <= 1'b1;
                    // Master drives NACK (1) for last byte
                    o_sda_t <= 1'b0; 
                    o_sda_o <= 1'b1; 

                    if (clk_cnt == CLKS_PER_BIT/2 && scl_int) begin 
                        state_reg <= S_STOP;
                    end
                end

                S_STOP: begin
                    o_i2c_busy <= 1'b1;
                    
                    // Stop Condition: SDA high while SCL is high.
                    if (scl_int == 1'b0) begin 
                        o_sda_t <= 1'b0; // Drive SDA low first
                        o_sda_o <= 1'b0; 
                    end else if (scl_int == 1'b1 && clk_cnt == CLKS_PER_BIT - 2) begin 
                        o_sda_t <= 1'b1; // Release SDA (it goes high)
                        state_reg <= S_IDLE; 
                    end
                end

                default: state_reg <= S_IDLE;
            endcase
        end
    end
    
endmodule