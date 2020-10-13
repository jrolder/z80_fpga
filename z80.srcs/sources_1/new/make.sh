#!/bin/sh -xe
~/zasm/zasm -buw --ixcbr2 testbench.asm
python3 tohex.py
python3 make_ucode.py
