class fifo_coverage #(int DEPTH = 8) extends uvm_component;
    `uvm_component_utils(fifo_coverage)

    // analysis port connection
    uvm_analysis_imp #(fifo_item, fifo_coverage) analysis_export;

    // virtual interface to sample 
    virtual dut_if vif;

    // depth tracking
    int unsigned depth;

    // local parameters for bins
    localparam int MAXDEPTH = DEPTH;
    localparam int MID_LOW  = 2;
    localparam int MID_HIGH = DEPTH - 2;

    covergroup fifo_cg;
        cp_op : coverpoint {vif.wr_en, vif.rd_en} {
            bins idle = {2'b00};
            bins write_only = {2'b10};
            bins read_only = {2'b01};
            bins simultanious = {2'b11};
        }
        cp_depth : coverpoint depth {
            bins empty = {0};
            bins full = {DEPTH};

            bins almost_empty = {1};
            bins almost_full = {DEPTH - 1};

            bins mid[] = {[MID_LOW:MID_HIGH]} with (MID_HIGH >= MID_LOW);
        }
        cp_empty : coverpoint vif.empty {
            bins empty_0 = {1'b0};
            bins empty_1 = {1'b1};
        }
        cp_full : coverpoint vif.full {
            bins full_0 = {1'b0};
            bins full_1 = {1'b1};
        }
        // Cross 
        cross_op_depth : cross cp_op, cp_depth;

        cross_op_flags : cross cp_op, cp_full, cp_empty;
    endgroup

    // constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        fifo_cg = new();
        depth = 0;
    endfunction

    // build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Coverage: Virtual Interface not found")
    endfunction

    // write method sampling point
    function void write(fifo_item tr);

        // update depth track all attempts

        // write attempt
        if(tr.wr_en && !tr.is_read_sample) begin
            if(!tr.full) begin
                depth++;
            end
            // else illegal write attempt depth unchanged
        end

        // read
        if(tr.is_read_sample) begin
            if(!tr.empty) begin
                depth--;
            end
            // else illegal read attempt depth unchanged
        end

        // safety depth overflow or underflow
        if(depth > DEPTH) depth = DEPTH;
        if(depth < 0) depth = 0;
        
        // cg sample
        fifo_cg.sample();
    endfunction
endclass