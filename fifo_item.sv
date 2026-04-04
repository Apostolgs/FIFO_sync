class fifo_item extends uvm_sequence_item;
  rand bit       wr_en;
  rand bit       rd_en;
  rand bit [7:0] data;

  bit [7:0] dout; // observed output
  bit is_read_sample; // is valid read 
  bit full; 
  bit empty;

  `uvm_object_utils(fifo_item)

  constraint read_write_bias {wr_en dist {0:=40, 1:=60};
                              rd_en dist {0:=60, 1:=40};} // writes 60% of the time, reads 40% of the time

  constraint valid_op {wr_en || rd_en;} //at least one of read or write will be active

  function new(string name = "fifo_item");
    super.new(name);
  endfunction
endclass
