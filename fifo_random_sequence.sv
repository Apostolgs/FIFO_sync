class fifo_random_sequence extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_random_sequence)

  function new(string name = "fifo_random_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_item req;
    repeat (50) begin
      `uvm_info("SEQ", "Starting random sequence body", UVM_MEDIUM);
      req = fifo_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end
  endtask
endclass
