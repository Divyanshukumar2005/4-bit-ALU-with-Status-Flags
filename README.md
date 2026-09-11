<div align="center">

# 4-bit ALU with Status Flags

A 4-bit Arithmetic Logic Unit in Verilog — eight arithmetic/logic operations, plus carry-out, overflow, and zero flags derived directly from the arithmetic path rather than bolted on separately. Verified through simulation and gate-level synthesis, not just behavioural code that happens to compile.

![Verilog](https://img.shields.io/badge/HDL-Verilog%20(IEEE%201364)-blue)
![Icarus](https://img.shields.io/badge/Simulated%20with-Icarus%20Verilog-orange)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

## Contents

- [Why](#why)
- [How it works](#how-it-works)
- [Supported operations](#supported-operations)
- [Verification](#verification)
- [Running it](#running-it)
- [Repository structure](#repository-structure)
- [What I'd add next](#what-id-add-next)
- [License](#license)

## Why

An ALU is one of those blocks everyone "understands" conceptually before actually building one — until you sit down and realize the flags are the part that actually needs care. `carry_out` and `overflow` aren't independent signals you can just tack on after the fact; they only mean something if they're read off the *same* extended-width computation the result comes from. Get that wrong and the ALU will still "work" for every normal test case, and then quietly give the wrong overflow flag on the one input pattern where it actually matters.

So the goal here wasn't just "an ALU that adds and subtracts" — it was to derive every flag from the actual arithmetic hardware, then prove it two separate ways: a self-checking testbench that specifically targets the flag edge cases (not just typical inputs), and running the design through Yosys to confirm it's real synthesizable RTL and not behavioural code that only happens to simulate correctly.

## How it works

The ALU takes two 4-bit operands (`a`, `b`), a 3-bit opcode, and an `enable` input, and produces a 4-bit result `y` plus three status flags:

- **`carry_out`** comes from the 5th bit of the extended-width result of the add/subtract path — not computed separately, so it can't drift out of sync with the actual arithmetic.
- **`overflow`** uses the standard two's-complement rule: it's only possible when both operands share a sign and the result's sign doesn't match theirs.
- **`zero`** is checked independently of the opcode, whenever `y` evaluates to `0000` — so it's meaningful for logic ops too, not just arithmetic.

When `enable` is low, `y` is forced to `0000` and the arithmetic flags default to `0`.

## Supported operations

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

## Verification

### Simulation

Simulated with Icarus Verilog on EDA Playground. The testbench is **self-checking** — every test case compares the DUT's actual output against a hand-computed expected value and prints `PASS`/`FAIL`, ending with an `ALL TESTS PASSED` (or `N TEST(S) FAILED`) summary.

It first sweeps through all eight opcodes with `enable` low to confirm the output stays at zero, then repeats the sweep with `enable` high. After that, it runs four targeted corner cases instead of stopping at "typical" inputs — unsigned carry-out (`1111 + 0001`), positive overflow (`0111 + 0001`), negative overflow (`1000 - 0001`), and the zero flag (`a XOR a`) — because that's exactly where flag logic tends to quietly break.

![Simulation waveform](images/simulation_waveform.png)

The waveform above confirms the flags assert at exactly the cycles where they're expected to.

### Synthesis

To confirm this is synthesizable RTL and not just simulatable behavioural code, I ran the design through Yosys and generated the gate-level schematic below.

![Yosys synthesis schematic](images/yosys_synthesis_schematic.png)

## Running it

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

Either way, this prints a `PASS`/`FAIL` line per test case (plus a final summary) and writes `alu.vcd`, which can also be opened in EPWave on [EDA Playground](https://www.edaplayground.com/).

## Repository structure

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

## What I'd add next

- Parameterize the width (`N`-bit instead of hardcoded 4-bit), so the same design scales without rewriting it
- Add a proper negative/sign flag alongside the existing three — useful for comparison operations that this ALU doesn't currently expose
- Replace the hand-written corner cases in the testbench with SystemVerilog assertions, so the flag rules are checked continuously rather than only at the specific inputs I thought to test
- Wrap this in a minimal datapath (register file + this ALU + a simple control unit) as the next step toward an actual toy CPU

## License

<div align="center">

MIT — see [LICENSE](LICENSE).

</div>
