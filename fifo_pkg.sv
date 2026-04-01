package fifo_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "fifo_item.sv"
  `include "fifo_random_sequence.sv"
  `include "fifo_write_sequence.sv"
  `include "fifo_read_sequence.sv"
  `include "fifo_driver.sv"
  `include "fifo_monitor.sv"
  `include "fifo_sequencer.sv"
  `include "fifo_agent.sv"
  `include "fifo_scoreboard.sv"
  `include "fifo_env.sv"
  `include "fifo_test.sv"

endpackage
