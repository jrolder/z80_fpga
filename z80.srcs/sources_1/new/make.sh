#!/bin/sh -xe
~/rasm/rasm.exe -oa testbench.asm
python tohex.py
python make_ucode.py
