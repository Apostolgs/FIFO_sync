class fifo_coverage #(int DEPTH = 8) extends uvm_component;
    `uvm_component_utils(fifo_coverage)

    // analysis port connection
    uvm_analysis_imp #(fifo_item, fifo_coverage) analysis_export;

    // virtual interface to sample 
    virual dut_if vif;

    // depth tracking
    int unsigned depth

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

            bins mid[] = {[MID_LOW:MID_HIGH]} if (MID_HIGH >= MID_LOW);
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
        cross_op_depth = cross cp_op, cp_depth;

        cross_op_flags = cross cp_op, cp_full, cp_empty;
    endgroup

    

endclass