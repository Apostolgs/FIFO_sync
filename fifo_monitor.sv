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

  wait (vif.rst_n == 1'b1);

  forever begin
    @(posedge vif.clk);

    /*
    // write
    if (vif.wr_en) begin
      tr = fifo_item::type_id::create("tr", this);
      tr.wr_en = 1;
      tr.rd_en = 0;
      tr.data  = vif.din;
      tr.is_read_sample = 0;
      tr.full  = vif.full;
      tr.empty = vif.empty;

      tr.write_accepted = !vif.full;
      tr.read_accepted = 0;

      mon_ap.write(tr);

      `uvm_info("MON",
        $sformatf("WRITE: data=0x%0h", tr.data),
        UVM_MEDIUM)
    end

    // read
    if (vif.rd_en) begin
      fork
        begin
          @(posedge vif.clk);

          rd_tr = fifo_item::type_id::create("rd_tr", this);
          rd_tr.wr_en = 0;
          rd_tr.rd_en = 1;
          rd_tr.dout  = vif.dout;
          rd_tr.is_read_sample = 1;
          rd_tr.full  = vif.full;
          rd_tr.empty = vif.empty;

          rd_tr.write_accepted = 0;
          rd_tr.read_accepted = !vif.empty;

          mon_ap.write(rd_tr);

          `uvm_info("MON",
            $sformatf("READ: dout=0x%0h", rd_tr.dout),
            UVM_MEDIUM)
        end
      join_none
    end
    */


    // new approach
    tr = fifo_item::type_id::create("tr", this);

    // capture signals
    tr.wr_en = vif.wr_en;
    tr.rd_en = vif.rd_en;
    tr.data  = vif.din;
    tr.dout  = vif.dout;

    tr.full  = vif.full;
    tr.empty = vif.empty;

    // acceptance
    tr.write_accepted = vif.wr_en && !vif.full;
    tr.read_accepted  = vif.rd_en && !vif.empty;

    // mark read sample valid immediately
    tr.is_read_sample = tr.rd_en;

    mon_ap.write(tr);
  end
endtask


endclass
