# Y86-64-Processor
This project involves the design and implementation of a processor architecture based on the Y86 Instruction Set Architecture (ISA) using Verilog. It includes both sequential and pipelined processor designs, thoroughly tested to meet specification requirements through simulations.

---

## Project Overview
The primary objectives of this project are:
- Develop a Y86-64 processor that implements sequential and pipelined architectures.
- Support all Y86 instructions except `call` and `ret` (with additional marks for implementing these).
- Design modular processor stages and thoroughly test each module and the integrated system using test cases.

---

## Specifications

### Sequential Architecture:
- Implements the following stages:
  1. Fetch
  2. Decode
  3. Execute
  4. Memory Access
  5. PC Update
- Executes all Y86 instructions except `call` and `ret`.
- Provides a baseline design for functionality.

### Pipelined Architecture:
- Implements a 5-stage pipeline with support for:
  - Data and control hazard elimination
  - Forwarding and stalling mechanisms
- Fully integrated design to enhance performance.

### Additional Features:
- Executes `call` and `ret` instructions for enhanced functionality.
- Comprehensive test case coverage, including provided and custom test cases.

---

## Design Approach
The design is modular, with each processor stage implemented as an independent Verilog module:
- **Fetch Stage**: Fetches instructions and updates the PC.
- **Decode Stage**: Decodes instructions and fetches operands.
- **Execute Stage**: Performs ALU operations and evaluates conditions.
- **Memory Access Stage**: Handles memory read/write operations.
- **Writeback Stage**: Writes results to registers.

Integration testing ensures seamless interaction between stages. Each module is tested independently before integration.

---

## Features
- Sequential design with all essential stages of the Y86 ISA.
- Pipelined design for improved throughput and performance.
- Support for pipeline hazard detection and resolution.
- Modular design for easy testing and debugging.
- Automated testbench for efficient verification.
- Test cases covering:
  - Basic operations.
  - Complex scenarios, including hidden test cases.

---

## Testing and Verification
1. **Unit Testing**:
   - Each module (e.g., Fetch, Decode) is tested independently using specific test inputs.
2. **Integration Testing**:
   - Integrated processor design tested with Y86 assembly programs.
3. **Custom Test Cases**:
   - Includes machine-encoded instructions for algorithms (e.g., sorting) to validate full functionality.
4. **Provided Test Cases**:
   - Includes sample test cases for verification.

---
