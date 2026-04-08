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

  // SVA SECTION

  default clocking cb @(posedge clk);
  endclocking
  
  default disable iff (!rst_n);

  property count_equal_DEPTH_when_full;
    full |-> count == DEPTH;
  endproperty

  assert property (count_equal_DEPTH_when_full)
  else $error("Time = %0t\tcount != DEPTH when full", $time);

  property count_equal_0_when_empty;
    empty |-> count == 0;
  endproperty

  assert property (count_equal_0_when_empty)
  else $error("Time = %0t\tcount != 0 when empty", $time);

  property simultanious_full_empty;
    !(full && empty);
  endproperty

  assert property (simultanious_full_empty)
  else $error("Time = %0t\tempty and full flags raised simultaniously", $time);

  property count_write_only;
    (wr_en && !rd_en) |-> count == $past(count) + 1;
  endproperty

  property count_read_only;
    (!wr_en && rd_en) |-> count == $past(count) - 1;
  endproperty

  property count_simultanious_read_write;
    (wr_en && rd_en) |-> count == $past(count);
  endproperty

  property count_stable_on_idle;
    (!wr_en && !rd_en) |-> count == $past(count);
  endproperty

  assert property (count_write_only)
  else $error("Time = %0t\tIllegal counting when write only", $time);

  assert property (count_read_only)
  else $error("Time = %0t\tIllegal counting when read only", $time);

  assert property (count_simultanious_read_write)
  else $error("Time = %0t\tIllegal counting when simultanious read write", $time);

  assert property (count_stable_on_idle)
  else $error("Time = %0t\tIllegal counting when idle", $time);

  property idle_op_then_stable_state;
    !(wr_en || rd_en) |-> $stable(full) && $stable(empty) && $stable(count);
  endproperty

  assert property (idle_op_then_stable_state)
  else $error("Time = %0t\tIdle operation and changed state", $time);

endinterface
