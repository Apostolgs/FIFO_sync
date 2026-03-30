class fifo_item extends uvm_sequence_item;
  rand bit       wr_en;
  rand bit       rd_en;
  rand bit [7:0] data;

  `uvm_object_utils(fifo_item)

  function new(string name = "fifo_item");
    super.new(name);
  endfunction
endclass
