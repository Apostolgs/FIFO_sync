`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_pkg.sv"
import fifo_pkg::*;

module FIFO_sync_TB;
  parameter int DEPTH = 8;
  parameter int DATA_WIDTH = 8;

  bit clk;
  dut_if #(DEPTH, DATA_WIDTH) dut_vi (.clk(clk));
  dut_wrapper #(DEPTH, DATA_WIDTH) dut_wr (._if(dut_vi));
  
  always #2.5 clk = ~clk;

  initial begin
    clk = 0;
    dut_vi.rst_n = 0;
    dut_vi.wr_en = 0;
    dut_vi.rd_en = 0;
    dut_vi.din   = '0;
    repeat (2) @(posedge clk);
    dut_vi.rst_n = 1;
  end

  initial begin
    uvm_config_db#(virtual dut_if)::set(null, "*", "vif", dut_vi);
    run_test();
  end
  
  initial begin
  	#10us;
  	`uvm_fatal("TIMEOUT", "Test timed out")
  end

endmodule
