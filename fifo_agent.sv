class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)

  fifo_driver    drv;
  fifo_sequencer seqr;
  fifo_monitor   mon;   // NEW

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv  = fifo_driver::type_id::create("drv", this);
    seqr = fifo_sequencer::type_id::create("seqr", this);
    mon  = fifo_monitor::type_id::create("mon", this); // NEW
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
