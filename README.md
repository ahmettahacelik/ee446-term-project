# Single-Cycle RISC-V Processor

This project implements a single-cycle RISC-V processor in HDL as part of the **EE446 Computer Architecture II** course. The processor supports a subset of the **RV32I** base instruction set.

## ✅ Instruction Set Implemented

| Type   | Instructions |
|--------|--------------|
| R-type | `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu` |
| I-type | `addi`, `andi`, `ori`, `xori`, `lw`, `lh`, `lb`, `jalr`, `slti`, `sltiu` |
| S-type | `sw`, `sh`, `sb` |
| B-type | `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu` |
| U-type | `lui`, `auipc` |
| J-type | `jal` |

## 📚 References

- [RISC-V Unprivileged ISA Specification (RV32I)](https://github.com/riscv/riscv-isa-manual)
- Implemented based on EE446 course materials and project guidelines.
- [RISC-V Reference](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf)
- [RISC-V Cheat Sheet](https://projectf.io/posts/riscv-cheat-sheet/)

