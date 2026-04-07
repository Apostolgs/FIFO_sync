class fifo_random_sequence extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_random_sequence)

  function new(string name = "fifo_random_sequence");
    super.new(name);
  endfunction

  task body();
    fifo_item req;
    `uvm_info("SEQ", "Starting random sequence body with valid operation constraint", UVM_MEDIUM);
    repeat (200) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {wr_en || rd_en;}); // valid operation constrained, will either read, write or both
      finish_item(req);
    end

    `uvm_info("SEQ", "Starting random sequence body without valid operation constraint", UVM_MEDIUM);
    repeat (200) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      assert(req.randomize()); // can be idle
      finish_item(req);
    end
  endtask
endclass
