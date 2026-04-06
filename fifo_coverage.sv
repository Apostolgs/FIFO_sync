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
        option.per_instance = 1;
        cp_op : coverpoint {vif.wr_en, vif.rd_en} {
            ignore bins idle = {2'b00};
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
        cp_write_accepted : coverpoint tr.write_accepted {
            bins wr_accepted = {1'b1};
            bins wr_not_accepted = {1'b0};
        }
        cp_read_accepted : coverpoint tr.read_accepted {
            bins rd_accepted = {1'b1};
            bins rd_not_accepted = {1'b0};
        }
        // Cross 
        op_X_depth : cross cp_op, cp_depth;

        op_X_flags : cross cp_op, cp_full, cp_empty;

        write_accepted_X_op : cross cp_write_accepted, cp_op;

        read_accepted_X_op : cross cp_read_accepted, cp_op;

        write_accepted_X_full : cross cp_write_accepted, cp_full;

        write_accepted_X_empty : cross cp_write_accepted, cp_empty;

        read_accepted_X_full : cross cp_read_accepted, cp_full;

        read_accepted_X_empty : cross cp_read_accepted, cp_empty;

        op_X_depth_X_legal : cross cp_op, cp_depth, cp_write_accepted, cp_read_accepted;
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
        if(tr.wr_en && tr.write_accepted) begin
            depth++;
        end
        else pass; // else illegal write attempt depth unchanged


        // read
        if(tr.rd_en && tr.read_accepted) begin
            depth--;
        end
        else pass; // else illegal read attempt depth unchanged

        // safety depth overflow or underflow
        if(depth > DEPTH) depth = DEPTH;
        if(depth < 0) depth = 0;
        
        // cg sample
        fifo_cg.sample();
    endfunction
endclass