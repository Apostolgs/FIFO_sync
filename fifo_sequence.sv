class fifo_sequence extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_sequence)

  function new(string name = "fifo_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_item req;
    repeat (10) begin
      `uvm_info("SEQ", "Starting sequence body", UVM_MEDIUM);
      req = fifo_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end
  endtask
endclass
