# Single-Cycle RISC-V Processor

This project implements a single-cycle RISC-V processor in HDL as part of the **EE446 Computer Architecture II** course. The processor supports a subset of the **RV32I** base instruction set.

## 📜 INSTRUCTION SET IMPLEMENTED

| Category               | Instructions                              |
|------------------------|-------------------------------------------|
| ARITHMETIC INSTRUCTIONS | ADD[I], SUB                               |
| LOGIC INSTRUCTIONS     | AND[I], OR[I], XOR[I]                      |
| SHIFT INSTRUCTIONS     | SLL[I], SRL[I], SRA[I]                     |
| SET IF LESS THAN       | SLT[I][U]                                  |
| CONDITIONAL BRANCH     | BEQ, BNE, BLT[U], BGE[U]                   |
| UNCONDITIONAL JUMP     | JAL, JALR (Return-address stack push/pop functionality will not be implemented) |
| LOAD                   | LW, LH[U], LB[U]                           |
| STORE                  | SW, SH, SB                                 |
| OTHERS                 | LUI, AUIPC                                 |


## 📚 Additional References

- [The RISC-V Instruction Set Manual, Volume I, Unprivileged Architecture](https://drive.google.com/file/d/1uviu1nH-tScFfgrovvFCrj7Omv8tFtkp/view)
- [RISC-V Reference](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf)
- [RISC-V Cheat Sheet](https://projectf.io/posts/riscv-cheat-sheet/)

