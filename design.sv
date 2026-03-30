`include "interface.sv"
`include "wrapper.sv"

module FIFO_sync #(
  parameter int DEPTH      = 8,
  parameter int DATA_WIDTH = 8
)(
  input  logic                 clk,
  input  logic                 rst_n,

  input  logic [DATA_WIDTH-1:0] din,
  input  logic                 wr_en,
  input  logic                 rd_en,

  output logic [DATA_WIDTH-1:0] dout,
  output logic                 full,
  output logic                 empty,
  output logic [$clog2(DEPTH+1)-1:0] count
);

  // -------------------------------------------------
  localparam int ADDR_W = $clog2(DEPTH);
  localparam int PTR_W  = ADDR_W + 1;

  logic [PTR_W-1:0] wr_ptr, rd_ptr;
  logic [DATA_WIDTH-1:0] fifo [0:DEPTH-1];

  // -------------------------------------------------
  // Write logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      wr_ptr <= '0;
    end
    else if (wr_en && !full) begin
      fifo[wr_ptr[ADDR_W-1:0]] <= din;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end

  // -------------------------------------------------
  // Read logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      rd_ptr <= '0;
      dout   <= '0;
    end
    else if (rd_en && !empty) begin
      dout   <= fifo[rd_ptr[ADDR_W-1:0]];
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

  // -------------------------------------------------
  // Status flags
  always_comb begin
    empty = (wr_ptr == rd_ptr);
    full  = (wr_ptr[PTR_W-1] != rd_ptr[PTR_W-1]) &&
            (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]);
  end

  // -------------------------------------------------
  // FIFO count
  always_ff @(posedge clk) begin
    if (!rst_n)
      count <= '0;
    else begin
      case ({wr_en && !full, rd_en && !empty})
        2'b10: count <= count + 1'b1; // write only
        2'b01: count <= count - 1'b1; // read only
        default: count <= count;      // no change or simultaneous
      endcase
    end
  end

endmodule