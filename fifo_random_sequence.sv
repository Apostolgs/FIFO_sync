class fifo_random_sequence extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_random_sequence)

  function new(string name = "fifo_random_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_item req;
    repeat (200) begin
      `uvm_info("SEQ", "Starting random sequence body with valid operation constraint", UVM_MEDIUM);
      req = fifo_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {wr_en || rd_en;}); // valid operation constrained, will either read, write or both
      finish_item(req);
    end

    repeat (100) begin
      `uvm_info("SEQ", "Starting random sequence body without valid operation constraint", UVM_MEDIUM);
      req = fifo_item::type_id::create("req");
      start_item(req);
      assert(req.randomize()); // can be idle
      finish_item(req);
    end
  endtask
endclass
