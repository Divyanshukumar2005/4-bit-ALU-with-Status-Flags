# 4-bit ALU with Status Flags (Verilog)

A 4-bit Arithmetic Logic Unit supporting 8 operations, with **Carry-out**, **Overflow**, and **Zero** status flags — the same kind of flag outputs found on real processor datapaths. Verified via simulation and synthesized to a gate-level netlist with Yosys.

## 📋 Supported Operations

| Opcode | Operation | Description |
|---|---|---|
| `000` | `y = a + b` | Addition — sets `carry_out` and `overflow` |
| `001` | `y = a - b` | Subtraction (2's complement) — sets `carry_out` and `overflow` |
| `010` | `y = a & b` | Bitwise AND |
| `011` | `y = a \| b` | Bitwise OR |
| `100` | `y = a ^ b` | Bitwise XOR |
| `101` | `y = ~a` | Bitwise NOT of `a` |
| `110` | `y = a << 1` | Logical left shift |
| `111` | `y = a >> 1` | Logical right shift |

When `enable = 0`, the output is forced to `0000` regardless of opcode.
