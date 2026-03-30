interface dut_if #(
  parameter int DEPTH = 8, 
  parameter int DATA_WIDTH = 8
)(
  input clk
);
  
  logic rst_n  ;
  logic [DATA_WIDTH-1:0] din;
  logic wr_en;
  logic rd_en;
  
  logic [DATA_WIDTH-1:0] dout;
  logic full;
  logic empty;
  logic [$clog2(DEPTH+1)-1:0] count;
  
  // TB side
  modport TB (
    input  full, empty, dout, count,
    output rst_n, din, wr_en, rd_en
  );

  // DUT side
  modport DUT (
    input  clk, rst_n, din, wr_en, rd_en,
    output full, empty, dout, count
  );
  
endinterface
