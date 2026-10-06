module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 4
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] wdata,

    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  full,
    output logic                  empty
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [$clog2(DEPTH)-1:0] wr_ptr;
    logic [$clog2(DEPTH)-1:0] rd_ptr;

    logic [$clog2(DEPTH+1)-1:0] count;

    
    // FIFO status
    
    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    
    // FIFO operation
    
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            rdata  <= 0;
        end

        else begin

            // WRITE
            if (wr_en && !full) begin
                mem[wr_ptr] <= wdata;

                if (wr_ptr == DEPTH-1)
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
            end

            // READ
            if (rd_en && !empty) begin
                rdata <= mem[rd_ptr];

                if (rd_ptr == DEPTH-1)
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
            end

            // COUNT
            case ({wr_en && !full, rd_en && !empty})

                2'b10: count <= count + 1;

                2'b01: count <= count - 1;

                2'b11: count <= count;

                default: count <= count;

            endcase
        end
    end

endmodule
