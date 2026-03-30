class fifo_driver extends uvm_driver #(fifo_item);
  `uvm_component_utils(fifo_driver)

  virtual dut_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface 'vif' not found in config DB")
  endfunction

  task run_phase(uvm_phase phase);
    fifo_item tr;

    wait (vif.rst_n === 1'b1);

    forever begin
      seq_item_port.get_next_item(tr);

      // Drive on negedge (so DUT samples on posedge)
      @(negedge vif.clk);
      vif.wr_en <= tr.wr_en;
      vif.rd_en <= tr.rd_en;
      vif.din   <= tr.data;

      // Hold for one cycle, then deassert
      @(posedge vif.clk);
      vif.wr_en <= 0;
      vif.rd_en <= 0;

      `uvm_info("DRV",
        $sformatf("Driving wr=%0b rd=%0b data=0x%0h", tr.wr_en, tr.rd_en, tr.data),
        UVM_MEDIUM)

      seq_item_port.item_done();
    end
  endtask

endclass
