import math

UCODE_LENGTH = 32
UCODE_ADDR_LENGTH = 12

bits = (
    "ip_to_addr",
    "rd")

enums = (
    ("decode", ("decode1", "decode2", "halt", "bdos")),
    ("read_target", ("rd_ir", "rd_arg1", "rd_arg2")),
    ("din8_target", ("din8_dst_ir543", )),
    ("din8_source", ("din8_src_dout8", "din8_src_ram")),
    ("dout8_sel", ("dout8_sel_ir210", )),
    ("din16_source", ("din16_src_arg12", "din16_src_dout16")),
    ("din16_sel", ("din16_sel_ir54q", )),
    ("flags_source", ("flags_source_alu8", )),
    ("alu8_source", ("alu8_src_ram", "alu8_src_dout8",)),
    ("alu8_op", ("alu8_op_ip543", )),
    ("ip_op", ("inc_ip", "ip_from_arg21"))
    )

def generate_ucode_headers():
  global bits
  global enums
  commands = {} # map of commands to constants
  current = UCODE_ADDR_LENGTH
  with open(HEADER_FILE, "w") as f:
    with open(UCODE_SIGNALS_FILE, "w") as g:
      f.write(f"parameter UCODE_LENGTH = {UCODE_LENGTH};\n")
      f.write(f"parameter UCODE_ADDR_LENGTH = {UCODE_ADDR_LENGTH};\n")
      for command in bits:
        name = command.upper()
        f.write(f"parameter UC_{name} = {1 << current};\n")
        g.write(f"wire uc_{command};\n")
        g.write(f"assign uc_{command} = ucode[{current}];\n")
        current += 1
        commands[command] = f"UC_{name}";
      for enum_name, enum_set in enums:
        n = len(enum_set) + 1 # plus one for not used
        bits = math.ceil(math.log2(n))
        enum_const = enum_name.upper()
        g.write(f"wire [{bits-1}:0] uc_{enum_name};\n")
        g.write(f"assign uc_{enum_name} = ucode[{current+bits-1}:{current}];\n")
        value = 1
        for enum in enum_set:
          f.write(f"parameter UC_{enum.upper()} = {value << current};\n")
          f.write(f"parameter VAL_{enum.upper()} = {value};\n")
          value += 1
          commands[enum] = f"UC_{enum.upper()}";
        current += bits;
  return commands

def make_codes(decode_map, opcode, chosen, uc_addr):
  if len(opcode) == 0:
    decode_map[int(chosen, 2)] = uc_addr
    return 
  bit = opcode[0]
  opcode = opcode[1:]
  if bit == "0" or bit == "1":
    make_codes(decode_map, opcode, chosen + bit, uc_addr)
  else:
    make_codes(decode_map, opcode, chosen + "0", uc_addr)
    make_codes(decode_map, opcode, chosen + "1", uc_addr)
    
    

def parse(uc_file, f, commands, ucodes, decode1):
  labels = {}
  current = 0;
  for line in f:
    line = line.rstrip()
    if len(line) == 0:
      continue
    if line.startswith("__opcode "):
      parts = line.split(" ", 2)
      opcode = parts[1]
      comment = parts[2]
      make_codes(decode1, opcode, "", current)
    elif line[0].isspace():
      # microcode line
      next_uc_addr = current + 1
      uc = []
      parts = line.strip().split()
      if parts[0] == "nop":
        parts = []
      i = 0
      while i < len(parts):
        if parts[i] == "goto":
          next_uc_addr = labels[parts[i+1]]
          i += 2
          continue
        uc.append(commands[parts[i]])
        i += 1
      uc.append(str(next_uc_addr))
      uc_file.write(f'      {current}: ucode <= {" | ".join(uc)};\n')
      current += 1
    else:
      # has to be a label
      if not line.endswith(":"):
        raise Exception("unexpected syntax: " + line)
      label = line[:-1]
      labels[label] = current
      
def write_decode_rom(filename, decode_map):  
  with open(filename, "w") as f:
    for value in sorted(decode_map.keys()):
      uc_addr = decode_map[value]
      f.write(f"      {value}: uc_addr <= {uc_addr};\n")    
      
      
    

UCODE_SRC_FILE = "z80.ucode"
HEADER_FILE = "ucode_consts.vh"
UCODE_SIGNALS_FILE = "ucode_signals.vh"
UCODE_FILE = "ucode.vh"
DECODE1_FILE = "decode1.vh"

ucodes = [] # list of tuples with ucode and comment
decode1 = {} # map of byte to ucode addr

commands = generate_ucode_headers()

with open(UCODE_SRC_FILE) as f:
  with open(UCODE_FILE, "w") as uc:
    parse(uc, f, commands, ucodes, decode1)

write_decode_rom(DECODE1_FILE, decode1)