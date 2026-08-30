# 4-bit ALU with Status Flags

A 4-bit Arithmetic Logic Unit implemented in Verilog, supporting eight arithmetic and logic operations along with carry-out, overflow, and zero status flags. The flag logic follows the same conventions used in processor datapaths, and the design has been verified through both simulation and gate-level synthesis.

## Overview

The ALU takes two 4-bit operands (`a`, `b`), a 3-bit opcode, and an enable input, and produces a 4-bit result `y` along with three status flags. The flags are derived directly from the arithmetic path rather than bolted on separately -- `carry_out` comes from the extended-width result of the add/subtract operation, and `overflow` is computed using the standard two's-complement sign-comparison rule (both operands share a sign, but the result's sign doesn't match).

When `enable` is low, `y` is forced to `0000` and the arithmetic flags default to `0`.

## Supported Operations

| Opcode | Operation | Notes |
|---|---|---|
| `000` | `y = a + b` | Sets `carry_out` and `overflow` |
| `001` | `y = a - b` | Two's-complement subtraction; sets `carry_out` and `overflow` |
| `010` | `y = a & b` | Bitwise AND |
| `011` | `y = a \| b` | Bitwise OR |
| `100` | `y = a ^ b` | Bitwise XOR |
| `101` | `y = ~a` | Bitwise NOT of `a` |
| `110` | `y = a << 1` | Logical left shift |
| `111` | `y = a >> 1` | Logical right shift |

`zero` is set independently of the opcode, whenever `y` evaluates to `0000`.

## Verification

### Simulation

Simulated with Icarus Verilog on EDA Playground. The testbench first sweeps through all eight opcodes with `enable` low to confirm the output stays at zero, then repeats the sweep with `enable` high. After that, it runs four targeted corner cases -- unsigned carry-out (`1111 + 0001`), positive overflow (`0111 + 0001`), negative overflow (`1000 - 0001`), and the zero flag (`a XOR a`) -- to check the flag logic at the boundaries rather than only for typical inputs.

![Simulation waveform](images/simulation_waveform.png)

The waveform above confirms the flags assert at exactly the cycles where they're expected to.

### Synthesis

To confirm this is synthesizable RTL and not just simulatable behavioural code, I ran the design through Yosys and generated the gate-level schematic below.

![Yosys synthesis schematic](images/yosys_synthesis_schematic.png)

## Running It

Requires [Icarus Verilog](http://iverilog.icarus.com/).

Using the included Makefile:

```bash
make sim     # compile and run the testbench
make wave    # open the resulting waveform in GTKWave
make clean   # remove generated files
```

Or manually:

```bash
iverilog -o alu_sim alu.v alu_tb.v
vvp alu_sim
```

Either way, this prints a time-stamped trace of every signal and writes `alu.vcd`, which can also be opened in EPWave on [EDA Playground](https://www.edaplayground.com/).

## Repository Structure

```
.
├── alu.v                  # ALU design
├── alu_tb.v                # Testbench
├── Makefile                 # Build/simulation shortcuts
├── images/
│   ├── simulation_waveform.png
│   └── yosys_synthesis_schematic.png
├── CHANGELOG.md
└── README.md
```

## Tools Used

- Verilog (IEEE 1364)
- Icarus Verilog, via EDA Playground, for simulation
- Yosys for gate-level synthesis
- GTKWave / EPWave for waveform inspection

## License

MIT -- see [LICENSE](LICENSE).
