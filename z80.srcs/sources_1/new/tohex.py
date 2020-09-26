with open("testbench.rom", "rb") as f:
  with open("ram.mem", "w") as g:
    while True:
      bytes = f.read(16)
      if len(bytes) == 0:
        break
      for b in bytes:
        g.write(f"{b:02x} ")
      g.write("\n")

