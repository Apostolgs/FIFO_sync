bind FIFO_sync fifo_sva #(
  .DEPTH(DEPTH),
  .DATA_WIDTH(DATA_WIDTH)
) fifo_sva_inst (
  .clk(clk),
  .rst_n(rst_n),
  .wr_en(wr_en),
  .rd_en(rd_en),
  .full(full),
  .empty(empty),
  .count(count),
  .dout(dout)
);
