!#/bin/sh -xe

~/zasm/zasm -buw zexdoc.z80
od -A x -t x1z zexdoc.rom > rom.hex
od -A x -t x1z zexdoc.com > com.hex
