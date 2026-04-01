class fifo_scoreboard extends uvm_component;
  `uvm_component_utils(fifo_scoreboard)

  // receives transactions from monitor
  uvm_analysis_imp #(fifo_item, fifo_scoreboard) imp;



  byte unsigned model_q[$];  // reference model queue

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Called automatically when monitor does ap.write(tr)
  function void write(fifo_item tr);
    // Model write
    if (tr.wr_en && !tr.is_read_sample) begin
      model_q.push_back(tr.data);
      `uvm_info("SCB", $sformatf("MODEL PUSH: 0x%0h (size=%0d)", tr.data, model_q.size()), UVM_LOW)
    end

    // Model read/compare
    if(tr.is_read_sample) begin
      if(model_q.size() == 0) begin
        `uvm_error("SCB", "Read occured but model is empty")
      end
      else begin
        byte unsigned exp = model_q.pop_front();

        if (tr.dout !== exp) begin
          `uvm_error("SCB", $sformatf("MISMATCH: expected=0x%0h got=0x%0h", exp, tr.dout))
        end
        else begin
          `uvm_info("SCB", $sformatf("MATCH: 0x%0h", tr.dout), UVM_LOW)
        end
      end
    end

  endfunction
endclass
