# Changelog

All notable changes to this project are documented here.

## [1.0.0] — Initial Release

- 4-bit ALU supporting 8 operations: add, subtract, AND, OR, XOR, NOT, logical left shift, logical right shift
- Carry-out, signed overflow, and zero status flags
- Testbench covering full opcode sweep plus targeted carry/overflow/zero corner cases
- Verified via Icarus Verilog simulation (EDA Playground) with EPWave waveform inspection
- Verified synthesizable via Yosys gate-level synthesis
