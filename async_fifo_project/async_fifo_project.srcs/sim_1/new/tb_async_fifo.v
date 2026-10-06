`timescale 1ns/1ps

module tb_async_fifo;

  // Parameters
  localparam DATA_WIDTH = 8;
  localparam ADDR_WIDTH = 4; // FIFO depth = 2^ADDR_WIDTH = 16

  // DUT signals
  reg wr_clk, rd_clk;
  reg wr_rst_n, rd_rst_n;
  reg wr_en, rd_en;
  reg [DATA_WIDTH-1:0] wr_data;
  wire [DATA_WIDTH-1:0] rd_data;
  wire full, empty;

  // Instantiate DUT
  async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) uut (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .wr_rst_n(wr_rst_n),
    .rd_rst_n(rd_rst_n),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
  );

  // Generate write clock (10ns period = 100MHz)
  initial wr_clk = 0;
  always #5 wr_clk = ~wr_clk;

  // Generate read clock (14ns period ? 71MHz)
  initial rd_clk = 0;
  always #7 rd_clk = ~rd_clk;

  // Test procedure
  integer i;
  initial begin
    // Init
    wr_rst_n = 0;
    rd_rst_n = 0;
    wr_en = 0;
    rd_en = 0;
    wr_data = 0;

    // Hold reset for a while
    #30;
    wr_rst_n = 1;
    rd_rst_n = 1;

    // Wait a bit before starting
    #20;

    // --- WRITE PHASE ---
    $display("---- Writing Data ----");
    for (i = 0; i < 8; i = i + 1) begin
      @(posedge wr_clk);
      if (!full) begin
        wr_en <= 1;
        wr_data <= i + 8'h10;  // Example pattern: 0x10, 0x11, ...
        $display("[%0t] Wrote: %h", $time, wr_data);
      end
    end
    @(posedge wr_clk);
    wr_en <= 0;

    // Wait until FIFO not empty
    wait (!empty);

    // --- READ PHASE ---
    $display("---- Reading Data ----");
    for (i = 0; i < 8; i = i + 1) begin
      @(posedge rd_clk);
      if (!empty) begin
        rd_en <= 1;
        @(posedge rd_clk); // wait 1 cycle for valid data
        $display("[%0t] Read: %h", $time, rd_data);
      end
    end
    @(posedge rd_clk);
    rd_en <= 0;

    #50;
    $display("Simulation Finished.");
    $stop;
  end

endmodule
