class fifo_test extends uvm_test;
  `uvm_component_utils(fifo_test)

  fifo_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_write_sequence wr_seq;
    fifo_read_sequence rd_seq;
    fifo_random_sequence rand_seq;
    fifo_idle_sequence idle_seq;
    fifo_read_write_sequence rd_wr_seq;

    phase.raise_objection(this);

    rd_wr_seq = fifo_read_write_sequence::type_id::create("rd_wr_seq");
    rd_wr_seq.start(env.agent.seqr);

    wr_seq = fifo_write_sequence::type_id::create("wr_seq");
    wr_seq.start(env.agent.seqr);

    idle_seq = fifo_idle_sequence::type_id::create("idle_seq");
    idle_seq.start(env.agent.seqr);

    rd_seq = fifo_read_sequence::type_id::create("rd_seq");
    rd_seq.start(env.agent.seqr);

    rand_seq = fifo_random_sequence::type_id::create("rand_seq");
    rand_seq.start(env.agent.seqr);

    phase.drop_objection(this);
  endtask
endclass
