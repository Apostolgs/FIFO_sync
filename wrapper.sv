module dut_wrapper #(
  parameter int DEPTH      = 8,
  parameter int DATA_WIDTH = 8
)(
  dut_if _if
);
  FIFO_sync #(DEPTH, DATA_WIDTH) FIFO_dut (
    .clk(_if.clk),
    .rst_n(_if.rst_n),
    .wr_en(_if.wr_en),
    .rd_en(_if.rd_en),
    .din(_if.din),
    
    .full(_if.full),
    .empty(_if.empty),
    .dout(_if.dout),
    .count(_if.count)
  );
endmodule