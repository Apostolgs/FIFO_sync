class fifo_read_sequence extends uvm_sequence #(fifo_item);
    `uvm_object_utils(fifo_read_sequence)

    function new(string name = "fifo_read_sequence");
        super.new(name);
    endfunction

    task body();
        fifo_item req;
        repeat (30) begin
            req = fifo_item::type_id::create("req");
            start_item(req);

            req.wr_en = 0;
            req.rd_en = 1;
            req.write_accepted = 0;
            req.read_accepted = !req.empty;
            assert(req.randomize() with {wr_en == 0; rd_en == 1;});
            finish_item(req);

            // idle for 1 cycle
            req = fifo_item::type_id::create("req");
            start_item(req);
            req.wr_en = 0;
            req.rd_en = 0;
            req.write_accepted = !req.full;
            req.read_accepted = 0;
            assert(req.randomize() with {wr_en == 0; rd_en == 0;});
            finish_item(req);
        end
    endtask
endclass
