class fifo_scoreboard extends uvm_component;
  `uvm_component_utils(fifo_scoreboard)

  // receives transactions from monitor
  uvm_analysis_imp #(fifo_item, fifo_scoreboard) imp;

  virtual dut_if vif;

  byte unsigned model_q[$];  // reference model queue

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface 'vif' not found in config DB")
  endfunction

  // Called automatically when monitor does ap.write(tr)
  function void write(fifo_item tr);
    `uvm_info("SCB", "Got transaction", UVM_LOW);
    // Model write
    if (tr.wr_en && !vif.full) begin
      model_q.push_back(tr.data);
    end

    // Model read/compare
    if (tr.rd_en && !vif.empty) begin
      if (model_q.size() == 0) begin
        `uvm_error("SCB", "DUT read when model queue is empty")
      end
      else begin
        byte unsigned exp = model_q.pop_front();

        // compare on next clock edge (1-cycle latency)
        fork
          begin
            @(posedge vif.clk);
            if (vif.dout !== exp) begin
              `uvm_error("SCB",
                $sformatf("Mismatch: expected dout=0x%0h got dout=0x%0h", exp, vif.dout))
            end
          end
        join_none
      end
    end

  endfunction
endclass
