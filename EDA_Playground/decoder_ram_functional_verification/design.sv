module decoder_ram(
  input clk,
  input rst_n,
  input w_enb,
  input r_enb,
  input [6:0] addr,
  input [7:0] wdata,
  output reg [7:0] rdata,
  output reg valid
);

  wire [3:0] cs;
  integer i;
  wire [4:0] word_addr;

  assign word_addr = addr[4:0];

  assign cs[0] = (addr[6:5] == 2'b00);
  assign cs[1] = (addr[6:5] == 2'b01);
  assign cs[2] = (addr[6:5] == 2'b10);
  assign cs[3] = (addr[6:5] == 2'b11);


  reg [7:0] mem_block0 [0:31];
  reg [7:0] mem_block1 [0:31];
  reg [7:0] mem_block2 [0:31];
  reg [7:0] mem_block3 [0:31];


  
  // WRITE
  always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin

      for(i = 0; i < 32; i = i + 1) begin
        mem_block0[i] = 0;
        mem_block1[i] = 0;
        mem_block2[i] = 0;
        mem_block3[i] = 0;
      end

    end

    else if (w_enb) begin

      case(cs)

        4'b0001 : mem_block0[word_addr] <= wdata;
        4'b0010 : mem_block1[word_addr] <= wdata;
        4'b0100 : mem_block2[word_addr] <= wdata;
        4'b1000 : mem_block3[word_addr] <= wdata;

      endcase

    end

  end


  
  // READ
  

  always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin

      rdata <= 8'h00;
      valid <= 1'b0;

    end

    else if (r_enb) begin

      valid <= 1'b1;

      case(cs)

        4'b0001 : rdata <= mem_block0[word_addr];
        4'b0010 : rdata <= mem_block1[word_addr];
        4'b0100 : rdata <= mem_block2[word_addr];
        4'b1000 : rdata <= mem_block3[word_addr];

        default: begin
          rdata <= 8'h00;
          valid <= 1'b0;
        end

      endcase

    end

    else begin
      valid <= 1'b0;
    end

  end

endmodule