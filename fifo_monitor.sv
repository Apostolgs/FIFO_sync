class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)

  virtual dut_if vif;
  uvm_analysis_port #(fifo_item) mon_ap;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction



  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Monitor: Virtual interface 'vif' not found in config DB")

    `uvm_info("MON", "build_phase: got vif", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
  fifo_item tr;
  fifo_item rd_tr;

  `uvm_info("MON", "run_phase started", UVM_LOW)

  // Don't rely on an event; just wait until reset is truly 1
  wait (vif.rst_n == 1'b1);
  `uvm_info("MON", "reset deasserted", UVM_LOW)

  forever begin
    // sample exactly when the driver drives
    @(posedge vif.clk);

    // Write observation
    if(vif.wr_en) begin
      tr = fifo_item::type_id::create("tr", this);
      tr.wr_en = 1;
      tr.rd_en = 0;
      tr.data = vif.din;
      tr.is_read_sample = 0;

      mon_ap.write(tr);

      `uvm_info("MON", $sformatf("WRITE : data = 0x%0h", tr.data), UVM_MEDIUM)
    end

    //Read request -> capture output next cycle
    if(vif.rd_en) begin
      fork begin
          @(posedge vif.clk);

          rd_tr = fifo_item::type_id::create("rd_tr", this);
          rd_tr.wr_en = 0;
          rd_tr.rd_en = 1;
          rd_tr.dout = vif.dout;
          rd_tr.is_read_sample = 1;

          mon_ap.write(rd_tr);

          `uvm_info("MON", $sformatf("READ: dout=0x%0h", rd_tr.dout), UVM_MEDIUM)
        end
      join_none
    end


    tr = fifo_item::type_id::create("tr", this);
    tr.wr_en = vif.wr_en;
    tr.rd_en = vif.rd_en;
    tr.data  = vif.din;

    // Only publish when there was an actual request
    if (tr.wr_en || tr.rd_en) begin
      mon_ap.write(tr);
      `uvm_info("MON",
        $sformatf("Sent tr wr=%0b rd=%0b data=0x%0h", tr.wr_en, tr.rd_en, tr.data),
        UVM_MEDIUM)
    end
  end
endtask


endclass
