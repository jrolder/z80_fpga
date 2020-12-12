!#/bin/sh -xe

~/zasm/zasm -buw zexdoc.z80
od -A x -t x1z zexdoc.rom > zexdoc.rom.hex
od -A x -t x1z zexdoc.com > zexdoc.com.hex

~/zasm/zasm -buw zexall.z80
od -A x -t x1z zexall.rom > zexall.rom.hex
od -A x -t x1z zexall.com > zexall.com.hex

~/zasm/zasm -buw zexwrap.z80
od -t x1 -A n -v zexwrap.rom > zexwrap.mem
