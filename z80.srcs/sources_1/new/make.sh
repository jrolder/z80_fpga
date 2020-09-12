#!/bin/sh -xe
~/rasm/rasm/rasm -oa testbench.asm
python3 tohex.py
python3 make_ucode.py
