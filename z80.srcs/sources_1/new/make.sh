#!/bin/sh -xe
~/zasm/zasm -buw --ixcbr2 testbench.asm
python3 tohex.py
python3 make_ucode.py
verilator --cc -Wno-WIDTH z80.v alu16.v alu_blk.v decode_cb_rom.v decode_xybits_rom.v registers.v sys_io.v ucode.v alu8.v decode1_rom.v decode_ed_rom.v decode_xy_rom.v sync_reset.v sys_ram.v --exe --build main.cpp
