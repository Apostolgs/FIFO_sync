# FIFO Sync UVM Verification

A parameterized synchronous FIFO design verified using a structured UVM environment with **functional coverage and SystemVerilog Assertions (SVA)**.

---

## Overview

This project demonstrates:

- A synthesizable synchronous FIFO (`design.sv`)
- A modular UVM verification environment
- Constrained-random and directed stimulus generation
- Scoreboard-based checking with a reference model
- Functional coverage for protocol and state exploration
- Assertion-based verification (SVA) bound to the DUT

The repository is intentionally kept **clean and flat**, similar to an EDA Playground setup, to focus on clarity and reproducibility.

---

## FIFO Design

The DUT is a synchronous FIFO with:

- Parameterizable depth and data width
- Separate read/write pointers
- Full / empty flag generation
- Count tracking

### Key Behavior

- Write occurs on `wr_en` when FIFO is not full
- Read occurs on `rd_en` when FIFO is not empty
- Read data (`dout`) is available **1 cycle after** `rd_en`

---

## Verification Architecture (UVM)

The UVM environment includes:

- **Sequences**
  - Random, directed, idle, and mixed read/write scenarios
  - Bias-controlled traffic generation

- **Driver**
  - Drives transactions on the negative clock edge
  - Ensures proper DUT sampling on the positive edge

- **Monitor**
  - Observes DUT signals
  - Reconstructs transactions (including delayed read data)
  - Tracks accepted vs rejected operations

- **Scoreboard**
  - Queue-based reference model
  - Cycle-accurate comparison of read data
  - Detects mismatches and underflow conditions

- **Coverage Collector**
  - Transaction-aware functional coverage
  - Tracks FIFO state, operations, and protocol legality

- **Agent / Environment / Test**
  - Standard UVM hierarchy
  - Fully connected analysis paths (monitor → scoreboard + coverage)

---

## Functional Coverage

Functional coverage is implemented in `fifo_coverage.sv` and includes:

### Coverpoints

- **Operation type**
  - Idle, write-only, read-only, simultaneous

- **FIFO depth**
  - Empty, full
  - Almost empty / almost full
  - Mid-range bins

- **Status flags**
  - `full`
  - `empty`

- **Transaction legality**
  - `write_accepted`
  - `read_accepted`

---

### Cross Coverage

- **Operation × Depth**
  - Detects illegal accesses

- **Operation × Flags**
  - Ensures correct flag behavior
  - Illegal: `full && empty`

- **Accepted Operations × Operation Type**
  - Validates protocol correctness

- **Accepted Operations × Flags**
  - Write cannot be accepted when full
  - Read cannot be accepted when empty

---

### Coverage Goals

- Exercise all FIFO states (empty → full transitions)
- Validate legal/illegal protocol behavior
- Ensure realistic traffic scenarios are explored
- Detect corner cases such as:
  - Simultaneous read/write
  - Boundary depth conditions

---

## Assertions (SVA)

Assertions are defined in `fifo_sva.sv` and **bound to the DUT** using `bind_fifo_sva.sv`.

### Verified Properties

- **Flag correctness**
  - `full → count == DEPTH`
  - `empty → count == 0`
  - `!(full && empty)`

- **Count behavior**
  - Write-only → count increments
  - Read-only → count decrements
  - Simultaneous read/write → count stable
  - Idle → count stable

- **Protocol correctness**
  - No illegal state transitions
  - Count consistency using `$past`

---

### Assertion Strategy

- Assertions are **non-intrusive** (bound externally)
- Automatically checked during simulation
- Provide immediate failure visibility with timestamps

---

## Stimulus Strategy

The test includes a mix of:

- Directed sequences:
  - Write bursts
  - Read bursts
  - Alternating read/write
  - Idle cycles

- Constrained-random sequences:
  - With and without valid-operation constraints
  - Biased read/write distribution

This ensures both:

- **Deterministic coverage of corner cases**
- **Exploration of unexpected scenarios**

---

## How to Run

Ensure Riviera-PRO (or a compatible simulator) is available, then run:

- `chmod +x run.sh`
- `./run.sh`

The script will:

1. Compile design and testbench files  
2. Run simulation with UVM  
3. Execute assertions  
4. Collect coverage data  
5. Print logs and generate coverage reports  

---

## Project Structure

### Design
- `design.sv`        → FIFO DUT
- `wrapper.sv`       → DUT wrapper
- `interface.sv`     → DUT interface

### Testbench
- `testbench.sv`     → top-level testbench

### UVM Components
- `fifo_pkg.sv`      → package
- `fifo_agent.sv`
- `fifo_env.sv`
- `fifo_driver.sv`
- `fifo_monitor.sv`
- `fifo_scoreboard.sv`
- `fifo_sequencer.sv`
- `fifo_test.sv`

### Sequences
- `fifo_random_sequence.sv`
- `fifo_write_sequence.sv`
- `fifo_read_sequence.sv`
- `fifo_idle_sequence.sv`
- `fifo_read_write_sequence.sv`

### Verification Enhancements
- `fifo_coverage.sv` → functional coverage
- `fifo_sva.sv`      → assertions
- `bind_fifo_sva.sv` → assertion binding

### Simulation
- `run.sh`
- `run.do`
- `library.cfg`

---

## Current Verification Features

- Constrained-random stimulus
- Directed test scenarios
- Transaction-level monitoring
- Scoreboard with reference model
- Functional coverage with cross bins
- Assertion-based verification (SVA)
- Handling of FIFO read latency (1-cycle delay)

---

## Future Improvements

- Coverage-driven stimulus refinement
- Functional coverage closure metrics
- Backpressure and stress testing
- Parameter sweep testing (different DEPTH/WIDTH)
- Formal verification (optional extension)
- Improved reference model decoupled from DUT timing
