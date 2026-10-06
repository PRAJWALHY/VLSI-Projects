`timescale 1ns/1ps

module apb_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS   = 16
)(
    input  logic                  PCLK,
    input  logic                  PRESETn,

    input  logic                  PSEL,
    input  logic                  PENABLE,
    input  logic                  PWRITE,

    input  logic [ADDR_WIDTH-1:0] PADDR,
    input  logic [DATA_WIDTH-1:0] PWDATA,

    output logic [DATA_WIDTH-1:0] PRDATA,
    output logic                  PREADY,
    output logic                  PSLVERR
);

    logic [DATA_WIDTH-1:0] reg_mem [0:NUM_REGS-1];

    logic [ADDR_WIDTH-1:0] reg_index;
    logic                  addr_valid;

    integer i;

    
    // ADDRESS DECODE
    

    always_comb begin

        reg_index = PADDR >> 2;

        if ((PADDR[1:0] == 2'b00) &&
            (PADDR < (NUM_REGS * 4)))
            addr_valid = 1'b1;
        else
            addr_valid = 1'b0;

    end


    
    // APB COMBINATIONAL RESPONSE
    

    always_comb begin

        PREADY  = 1'b0;
        PSLVERR = 1'b0;
        PRDATA  = '0;

        if (PRESETn && PSEL && PENABLE) begin

            // Zero-wait-state APB slave
            PREADY = 1'b1;

            // Invalid address
            if (!addr_valid)
                PSLVERR = 1'b1;

            // Read
            if (!PWRITE && addr_valid)
                PRDATA = reg_mem[reg_index];

        end

    end


    
    // REGISTER WRITE
    

    always_ff @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin

            for (i = 0; i < NUM_REGS; i = i + 1)
                reg_mem[i] <= '0;

        end

        else begin

            if (PSEL &&
                PENABLE &&
                PWRITE &&
                PREADY &&
                !PSLVERR) begin

                reg_mem[reg_index] <= PWDATA;

            end

        end

    end

endmodule