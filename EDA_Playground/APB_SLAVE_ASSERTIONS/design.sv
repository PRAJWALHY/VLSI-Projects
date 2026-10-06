`timescale 1ns/1ps

module apb_slave (
    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,

    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,

    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    logic [31:0] mem [0:255];

    integer i;

    always_ff @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin

            PREADY  <= 1'b0;
            PSLVERR <= 1'b0;
            PRDATA  <= 32'd0;

            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 32'd0;

        end

        else begin

            // Default outputs
            PREADY  <= 1'b0;
            PSLVERR <= 1'b0;

            // APB ACCESS phase
            if (PSEL && PENABLE) begin

                PREADY <= 1'b1;

                // Address 0 - 99 : READ ONLY
                if (PADDR <= 32'd99) begin

                    if (PWRITE) begin
                        PSLVERR <= 1'b1;
                    end
                    else begin
                        PRDATA <= mem[PADDR];
                    end

                end

                // Address 100 - 199 : WRITE ONLY
                else if (PADDR <= 32'd199) begin

                    if (PWRITE) begin
                        mem[PADDR] <= PWDATA;
                    end
                    else begin
                        PSLVERR <= 1'b1;
                    end

                end

                // Address 200 - 255 : READ / WRITE
                else if (PADDR <= 32'd255) begin

                    if (PWRITE) begin
                        mem[PADDR] <= PWDATA;
                    end
                    else begin
                        PRDATA <= mem[PADDR];
                    end

                end

                // Address > 255 : INVALID
                else begin

                    PSLVERR <= 1'b1;

                end

            end
        end

    end

endmodule