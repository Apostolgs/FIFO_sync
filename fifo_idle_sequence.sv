class fifo_idle_sequence extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_idle_sequence)

  function new(string name = "fifo_idle_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_item req;
    `uvm_info("SEQ", "Starting idle sequence body", UVM_MEDIUM);
    repeat (20) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      req.wr_en = 0;
      req.rd_en = 0;
      req.write_accepted = 0;
      req.read_accepted = 0;
      assert(req.randomize() with {wr_en == 0; rd_en == 0;});
      finish_item(req);
    end
  endtask
endclass
