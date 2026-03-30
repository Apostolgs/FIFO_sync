# FIFO Sync UVM Verification

A parameterized synchronous FIFO design verified using a minimal yet structured UVM testbench.

---

## Overview

This project demonstrates:
- A synthesizable synchronous FIFO (`design.sv`)
- A modular UVM verification environment
- Basic stimulus generation and checking using a scoreboard

The repository is intentionally kept **clean and flat**, similar to an EDA Playground setup, to focus on clarity and reproducibility.

---

## FIFO Design

The DUT is a synchronous FIFO with:
- Parameterizable depth and data width
- Separate read/write pointers
- Full / empty flag generation
- Count tracking

### Key behavior
- Write occurs on `wr_en` when FIFO is not full
- Read occurs on `rd_en` when FIFO is not empty
- Read data (`dout`) is available **1 cycle after** `rd_en`

---

## Verification Architecture (UVM)

The UVM environment includes:

- **Sequence**  
  Generates randomized read/write transactions

- **Driver**  
  Drives stimulus onto the DUT interface

- **Monitor**  
  Observes DUT activity and publishes transactions

- **Scoreboard**  
  Implements a reference model using a queue and checks DUT output

- **Agent / Environment / Test**  
  Standard UVM hierarchy for modularity and scalability

---

## How to Run

Ensure Riviera-PRO (or a compatible simulator) is available, then:

chmod +x run.sh
./run.sh


The script will:
1. Compile all design and testbench files
2. Run the simulation
3. Print UVM logs to the console

---

## Project Structure

- `design.sv`        → FIFO DUT
- `interface.sv`     → DUT interface
- `wrapper.sv`       → DUT wrapper
- `testbench.sv`     → top-level testbench

- `fifo_*.sv`        → UVM components
- `fifo_pkg.sv`      → UVM package

- `run.sh`           → compile & run script
- `library.cfg`      → simulator library config

## Notes

- Waveforms and logs are ignored via `.gitignore`
- Designed to resemble an EDA Playground-style setup

---

## Current Verification Features

- Random stimulus generation
- Transaction-level monitoring
- Scoreboard-based checking
- Handling of FIFO read latency (1-cycle delay)

---

## Future Improvements

- Constrained-random stimulus (better control of traffic)
- Directed test scenarios (full/empty boundary cases)
- Functional coverage
- Assertions (SVA)
- More accurate reference model (independent of DUT signals)

---
