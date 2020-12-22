# Verilog FPGA implementation of the Z80 microprocessor instruction set

This project has been on my bucket list for some time. 2020 being a weird year, I found cycle to finally sit down and just do it.

It is a Verilog implementation of the venerable Zilog Z80 instruction set, albeit without interrupt support. The code does pass zexall, the canonical Z80 impelementation test suite.

## Prerequisites

* Linux
* Python 3
* zasm (https://k1.spdns.de/Develop/Projects/zasm/Documentation/)
* verilator (https://www.veripool.org/wiki/verilator)
* verilator dependencies (gcc and others, see docs)

## Build

Run ./build.sh from repo root. This will run the assembler on the zexdoc/zexall sources, build the hand-crafted automated test for the Z80, "verilate" the Verilog code and finally run zexall.

To run zexdoc or the hand-crafted tests instead of zexall, edit sys_ram.v and rerun the build.

## Notes on zexdoc/zexdoc

As many folks have noted in their Z80 emulator endeavors, the zexall/zexdoc test suite requires assemblers that are no longer readily available. I have therefore modified the zexdoc/all sources to be compatible with zasm. The binary output is identical to the original binary files.
