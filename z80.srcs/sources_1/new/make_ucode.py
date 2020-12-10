import math

UCODE_LENGTH = 80
UCODE_ADDR_LENGTH = 12

bits = ("rd", )

enums = (
    ("command", ("halt", "bdos",)),
    ("ucode_goto", ("decode1", "decode_cb", "decode_xy", "decode_xybits", "decode_ed", "goto_now", "goto_ncc", "goto_nccr", "goto_z", "goto_po")),
    ("ram_addr_sel", ("addr_sel_ip", "addr_sel_dout16", "addr_sel_alu16", "addr_sel_tmp", "addr_sel_tmp_p1", "io_addr_sel_dout8", "io_addr_sel_tmp_lo")),
    ("read_target", ("rd_ir", "rd_tmp_lo", "rd_tmp_hi", "rd_tmp2_lo", "rd_tmp2_hi", "rd_tmp_from_dout16", "rd_tmp2_from_dout16", "rd_xy_off")),
    ("ram_wr_sel", ("ram_wr_dout8", "ram_wr_tmp_lo", "ram_wr_tmp_hi", "ram_wr_tmp2_lo", "ram_wr_tmp2_hi", "ram_wr_ip_hi", "ram_wr_ip_lo", "io_wr_dout8", "io_wr_tmp_lo", "io_wr_0", "ram_wr_alu8")),
    ("din8_target", ("din8_dst_ir210", "din8_dst_ir543", "din8_dst_a", "din8_dst_b", "din8_dst_h", "din8_dst_l","din8_dst_r", "din8_dst_i" )),
    ("din8_source", ("din8_src_dout8", "din8_src_ram", "din8_src_alu8", "din8_src_io")),
    ("dout8_sel", ("dout8_sel_ir543", "dout8_sel_ir210", "dout8_sel_rega", "dout8_sel_regb", "dout8_sel_regc", "dout8_sel_reg_h", "dout8_sel_reg_l",
                   "dout8_sel_reg_r", "dout8_sel_reg_i")),
    ("din16_source", ("din16_src_tmp", "din16_src_tmp2", "din16_src_dout16", "din16_src_alu16")),
    ("din16_sel", ("din16_sel_ir54rp1", "din16_sel_ir54rp2", "din16_sel_sp","din16_sel_hl","din16_sel_de", "din16_sel_bc")),
    ("dout16_sel", ("dout16_sel_bc", "dout16_sel_hl", "dout16_sel_sp", "dout16_sel_de", "dout16_sel_ir54rp","dout16_sel_ir54rp2",)),
    ("flags_source", ("flags_source_alu8", "flags_source_alu16", "flags_source_alu_blk")),
    ("alu8_source", ("alu8_src_ram", "alu8_src_dout8","alu8_src_tmp_lo", "alu8_src_io")),
    ("alu8_op", ("alu8_op_ip543", "alu8_op_ip543b", "alu8_op_ip543_cbrot", "alu8_op_inc", "alu8_op_dec", "alu8_op_bit", 
                 "alu8_op_res", "alu8_op_set", "alu8_op_in", "alu8_op_neg", "alu8_op_rrd_1", "alu8_op_rrd_2", "alu8_op_rld_1", "alu8_op_rld_2", )),
    ("ip_op", ("inc_ip", "ip_from_tmp", "ip_from_rel_tmp", "ip_from_rst")),
    ("alu16_op", ("alu16_op_inc", "alu16_op_dec", "alu16_op_dec_ld", "alu16_op_add","alu16_op_sbc","alu16_op_adc")),
    ("xy_sel", ("xy_sel_clear", "xy_sel_ix", "xy_sel_iy")),
    ("blk_latch", ("blk_latch_data",)),
    ("blk_op", ("blk_op_ld", )),
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
          f.write(f"parameter [{UCODE_LENGTH-1}:0] UC_{enum.upper()} = {value} << {current};\n")
          f.write(f"parameter VAL_{enum.upper()} = {value};\n")
          value += 1
          commands[enum] = f"UC_{enum.upper()}";
        current += bits;
  if current > UCODE_LENGTH:
      raise Exception(f"microcode too wide, increase UCODE_LENGTH to {current}")
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
    
    

def parse(uc_file, f, commands, ucodes, decode1, decode_cb, decode_xy, decode_xybits, decode_ed):
  labels = {}
  current = 0;
  for line in f:
    p = line.find(';')
    if p >= 0:
      line = line[:p]
    line = line.rstrip()
    if len(line) == 0:
      continue
    if line.startswith("__opcode "):
      parts = line.split(maxsplit=2)
      opcode = parts[1]
      comment = parts[2]
      make_codes(decode1, opcode, "", current)
    elif line.startswith("__opcode_cb "):
      parts = line.split(maxsplit=2)
      opcode = parts[1]
      comment = parts[2]
      make_codes(decode_cb, opcode, "", current)
    elif line.startswith("__opcode_xy "):
      parts = line.split(maxsplit=2)
      opcode = parts[1]
      comment = parts[2]
      make_codes(decode_xy, opcode, "", current)
    elif line.startswith("__opcode_xybits "):
      parts = line.split(maxsplit=2)
      opcode = parts[1]
      comment = parts[2]
      make_codes(decode_xybits, opcode, "", current)
    elif line.startswith("__opcode_ed "):
      parts = line.split(maxsplit=2)
      opcode = parts[1]
      comment = parts[2]
      make_codes(decode_ed, opcode, "", current)
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
          parts.append("goto_now") # imply gotonow
          continue
        if parts[i] == "gotoncc":
          next_uc_addr = labels[parts[i+1]]
          i += 2
          parts.append("goto_ncc")
          continue        
        if parts[i] == "gotonccr":
          next_uc_addr = labels[parts[i+1]]
          i += 2
          parts.append("goto_nccr") 
          continue        
        if parts[i] == "gotoz":
          next_uc_addr = labels[parts[i+1]]
          i += 2
          parts.append("goto_z") 
          continue        
        if parts[i] == "gotopo":
          next_uc_addr = labels[parts[i+1]]
          i += 2
          parts.append("goto_po") 
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
DECODE_CB_FILE = "decode_cb.vh"
DECODE_XY_FILE = "decode_xy.vh"
DECODE_XYBITS_FILE = "decode_xybits.vh"
DECODE_ED_FILE = "decode_ed.vh"

ucodes = [] # list of tuples with ucode and comment
decode1 = {} # map of byte to ucode addr
decode_cb = {} # map of byte to ucode addr
decode_xy = {} # map of byte to ucode addr
decode_xybits = {} # map of byte to ucode addr
decode_ed = {} # map of byte to ucode addr

commands = generate_ucode_headers()

with open(UCODE_SRC_FILE) as f:
  with open(UCODE_FILE, "w") as uc:
    parse(uc, f, commands, ucodes, decode1, decode_cb, decode_xy, decode_xybits, decode_ed)

write_decode_rom(DECODE1_FILE, decode1)
write_decode_rom(DECODE_CB_FILE, decode_cb)
write_decode_rom(DECODE_XY_FILE, decode_xy)
write_decode_rom(DECODE_XYBITS_FILE, decode_xybits)
write_decode_rom(DECODE_ED_FILE, decode_ed)
