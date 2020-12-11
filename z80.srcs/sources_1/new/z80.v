`timescale 1ns / 1ps



module z80(
    clk,
    reset_external,
    halt,
    ucode_addr_out,
    ucode_out,
    ir1_out,
    bc_out,
    arg_lo_out,
    arg_hi_out
    );

`include "ucode_consts.vh"
`include "z80_consts.vh"
    
// declarations for this module
input wire clk;
input wire reset_external;
output reg halt;
output wire [UCODE_ADDR_LENGTH-1:0] ucode_addr_out;
output wire [UCODE_LENGTH-1:0] ucode_out;
output wire [7:0] ir1_out;
output wire [15:0] bc_out;
output wire [7:0] arg_lo_out;
output wire [7:0] arg_hi_out;

// global declarations
reg [15:0] TMP;
reg [15:0] TMP2;
reg [15:0] IP;
reg [1:0] xy_sel;
reg [7:0] xy_off;

assign arg_lo_out = TMP[7:0];
assign arg_hi_out = TMP[15:8];
  
    
// module sync_reset  
wire reset;
    
sync_reset sync_reset(
  .reset_external(reset_external),
  .clk(clk),
  .reset(reset)
  );
    
// module ucode_rom    
reg [UCODE_ADDR_LENGTH-1:0] ucode_addr;
wire [UCODE_LENGTH-1:0] ucode;
wire [UCODE_ADDR_LENGTH-1:0] last_ucode_addr;
    
ucode_rom ucode_rom(
  .clk(clk),
  .reset(reset),
  .ucode_addr(ucode_addr),
  .last_ucode_addr(last_ucode_addr),
  .ucode(ucode)
  );


// module sys_ram
reg [15:0] ram_addr;
reg ram_we;
reg [7:0] ram_din;
wire [7:0] ram_dout;
    
sys_ram sys_ram(
  .addr(ram_addr),
  .we(ram_we),
  .clk(clk),
  .din(ram_din),
  .dout(ram_dout));
  

// module decode_rom
wire [UCODE_ADDR_LENGTH-1:0] decode1_out;
reg [7:0] IR1;

decode1_rom decode1_rom (
  .opcode(ram_dout),
  .uc_addr(decode1_out)
  );  
  
// module decode_cb
wire [UCODE_ADDR_LENGTH-1:0] decode_cb_out;

decode_cb_rom decode_cb_rom (
  .opcode(ram_dout),
  .uc_addr(decode_cb_out)
  );  

// module decode_xy (DD+FD prefix)
wire [UCODE_ADDR_LENGTH-1:0] decode_xy_out;

decode_xy_rom decode_xy_rom (
  .opcode(ram_dout),
  .uc_addr(decode_xy_out)
  );  

// module decode_xy bits (DDCB+FDCB prefix)
wire [UCODE_ADDR_LENGTH-1:0] decode_xybits_out;

decode_xybits_rom decode_xybits_rom (
  .opcode(ram_dout),
  .uc_addr(decode_xybits_out)
  );  

// module decode_ed_rom (extended (ED) prefix)
wire [UCODE_ADDR_LENGTH-1:0] decode_ed_out;

decode_ed_rom decode_ed_rom (
  .opcode(ram_dout),
  .uc_addr(decode_ed_out)
  );  
  
// module registers  
reg [7:0] reg_din8;
wire [7:0] reg_dout8;
reg [3:0] reg_din8sel;
reg [3:0] reg_dout8sel;
reg [15:0] reg_din16;
wire [15:0] reg_dout16;
reg [3:0] reg_din16sel;
reg [3:0] reg_dout16sel;
reg [7:0] reg_flags_in;
wire [7:0] reg_flags_out;
reg reg_din8we;
reg reg_din16we;
reg reg_flags_we;
wire [7:0] reg_aout8;

registers registers(
  .clk(clk),
  .reset(reset),
  .din8(reg_din8),
  .dout8(reg_dout8),
  .din8sel(reg_din8sel),
  .dout8sel(reg_dout8sel),
  .din16(reg_din16),
  .dout16(reg_dout16),
  .din16sel(reg_din16sel),
  .dout16sel(reg_dout16sel),
  .flags_in(reg_flags_in),
  .flags_out(reg_flags_out),
  .din8we(reg_din8we),
  .din16we(reg_din16we),
  .flags_we(reg_flags_we),
  .aout8(reg_aout8),
  .xy_sel(xy_sel)
  );  
  
// module alu8
wire [7:0] alu8_ain;
wire [7:0] alu8_out;
reg [5:0] alu8_op;
reg [7:0] alu8_arg;
wire [7:0] alu8_flags_in;
wire [7:0] alu8_flags_out;
wire [2:0] alu8_bit_sel;

alu8 alu8 (
  .alu8_ain(alu8_ain),
  .alu8_out(alu8_out),
  .alu8_op(alu8_op),
  .alu8_arg(alu8_arg),
  .alu8_flags_in(alu8_flags_in),
  .alu8_flags_out(alu8_flags_out),
  .alu8_bit_sel(alu8_bit_sel)
  );  
  
// module alu16    
wire [15:0] alu16_out;
wire [7:0] alu16_flags_out;
wire [2:0] alu16_op;

alu16 alu16 (
  .alu16_arg1(reg_dout16),
  .alu16_arg2(TMP),
  .alu16_out(alu16_out),
  .alu16_op(alu16_op),
  .alu16_flags_in(reg_flags_out),
  .alu16_flags_out(alu16_flags_out)
);  

// module sys_io
reg [7:0] io_addr;
wire [7:0] io_dout;
reg [7:0] io_din;
reg io_we;

sys_io sys_io(
  .clk(clk),
  .io_addr(io_addr),
  .io_dout(io_dout),
  .io_din(io_din),
  .io_we(io_we)
);

wire [7:0] alu_blk_flags_out;
wire blk_do_loop;

// module alu_blk
alu_blk alu_blk(
  .clk(clk),
  .reset(reset),
  .reg16(reg_dout16),
  .reg8(reg_dout8),
  .mem8(ram_dout),
  .io8(io_dout),
  .op(uc_blk_op),
  .latch_op(uc_blk_latch),
  .flags_in(reg_flags_out),
  .flags_out(alu_blk_flags_out),
  .do_loop(blk_do_loop)
  );

assign ucode_out = ucode;
assign ucode_addr_out = ucode_addr;

assign alu8_bit_sel = IR1[5:3];

`include "ucode_signals.vh"

  
function check_condition;
input [2:0] cond;
input [7:0] flags;
begin
  case (cond)
    0: check_condition = flags[6] == 0; // NZ
    1: check_condition = flags[6] == 1;// Z
    2: check_condition = flags[0] == 0;// NC
    3: check_condition = flags[0] == 1;// C
    4: check_condition = flags[2] == 0;// PO
    5: check_condition = flags[2] == 1;// PE
    6: check_condition = flags[7] == 0;// P
    7: check_condition = flags[6] == 1;// M
  endcase
end
endfunction

  
always @(*)
begin
  case (uc_ucode_goto)
    VAL_DECODE1:
      ucode_addr = decode1_out;
    VAL_DECODE_CB: 
      ucode_addr = decode_cb_out;
    VAL_DECODE_XY: 
      ucode_addr = decode_xy_out;
    VAL_DECODE_XYBITS: 
      ucode_addr = decode_xybits_out;
    VAL_DECODE_ED: 
      ucode_addr = decode_ed_out;
    VAL_GOTO_NOW: 
      ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
    VAL_GOTO_NCC:
      begin
        if (check_condition(IR1[5:3], reg_flags_out))
          ucode_addr = last_ucode_addr + 1;
        else
          ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
      end
    VAL_GOTO_NCCR:
      begin
        if (check_condition(IR1[4:3], reg_flags_out))
          ucode_addr = last_ucode_addr + 1;
        else
          ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
      end
    VAL_GOTO_Z:
      begin
        if (alu8_flags_out[6])
          ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
        else
          ucode_addr = last_ucode_addr + 1;
      end
    VAL_GOTO_LOOP: 
      begin
        if (blk_do_loop)
          ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
        else
          ucode_addr = last_ucode_addr + 1;
      end
    default:
      ucode_addr = last_ucode_addr + 1;
  endcase
end



always @(*)
begin
  case (uc_ram_wr_sel)
    VAL_RAM_WR_DOUT8:
      begin
        ram_din = reg_dout8;
        ram_we = 1;
      end
    VAL_RAM_WR_TMP_LO:
      begin
        ram_din = TMP[7:0];
        ram_we = 1;
      end
    VAL_RAM_WR_TMP_HI:
      begin
        ram_din = TMP[15:8];
        ram_we = 1;
      end
    VAL_RAM_WR_TMP2_LO:
      begin
        ram_din = TMP2[7:0];
        ram_we = 1;
      end
    VAL_RAM_WR_TMP2_HI:
      begin
        ram_din = TMP2[15:8];
        ram_we = 1;
      end
    VAL_RAM_WR_IP_HI:
      begin
        ram_din = IP[15:8];
        ram_we = 1;
      end
    VAL_RAM_WR_IP_LO:
      begin
        ram_din = IP[7:0];
        ram_we = 1;
      end
    VAL_RAM_WR_ALU8:
      begin
        ram_din = alu8_out;
        ram_we = 1;
      end
    default:
      begin
        ram_din = 8'bX;
        ram_we = 0;
      end
  endcase
end



  
assign bc_out = registers.BC;

always @(*)
begin
  case (uc_din8_source)
    VAL_DIN8_SRC_RAM: 
      begin
        reg_din8 = ram_dout;
        reg_din8we = 1;
      end
    VAL_DIN8_SRC_DOUT8:
      begin
        reg_din8 = reg_dout8;
        reg_din8we = 1;
      end
    VAL_DIN8_SRC_ALU8:
      begin
        reg_din8 = alu8_out;
        reg_din8we = 1;
      end    
    VAL_DIN8_SRC_IO:
      begin
        reg_din8 = io_dout;
        reg_din8we = 1;
      end    
    default:
      begin
        reg_din8 = 8'bX;
        reg_din8we = 0;
      end
  endcase
end

always @(*)
begin
  case (uc_din8_target)
    VAL_DIN8_DST_IR210: 
      reg_din8sel = IR1[2:0];
    VAL_DIN8_DST_IR543: 
      reg_din8sel = IR1[5:3];
    VAL_DIN8_DST_A:
      reg_din8sel = 7;
    VAL_DIN8_DST_B:
      reg_din8sel = 0;
    VAL_DIN8_DST_H:
      reg_din8sel = 4;
    VAL_DIN8_DST_L:
      reg_din8sel = 5;
    VAL_DIN8_DST_I:
      reg_din8sel = 12;
    VAL_DIN8_DST_R:
      reg_din8sel = 13;
    default:
      reg_din8sel = 4'bX;
  endcase
end

always @(*)
begin
  case (uc_dout8_sel)
    VAL_DOUT8_SEL_IR543: reg_dout8sel = IR1[5:3];
    VAL_DOUT8_SEL_IR210: reg_dout8sel = IR1[2:0];
    VAL_DOUT8_SEL_REGA: reg_dout8sel = 7;
    VAL_DOUT8_SEL_REGB: reg_dout8sel = 0;
    VAL_DOUT8_SEL_REGC: reg_dout8sel = 1;
    VAL_DOUT8_SEL_REG_H: reg_dout8sel = 4;
    VAL_DOUT8_SEL_REG_L: reg_dout8sel = 5;
    VAL_DOUT8_SEL_REG_I: reg_dout8sel = 12;
    VAL_DOUT8_SEL_REG_R: reg_dout8sel = 13;
    default:
      reg_dout8sel = 4'bX;
  endcase
end

always @(*)
begin
  case (uc_din16_source)
    VAL_DIN16_SRC_TMP: 
      begin
        reg_din16 = TMP;
        reg_din16we = 1;
      end
    VAL_DIN16_SRC_TMP2:  
      begin
        reg_din16 = TMP2;
        reg_din16we = 1;
      end
    VAL_DIN16_SRC_DOUT16:
      begin
        reg_din16 = reg_dout16;
        reg_din16we = 1;
      end
    VAL_DIN16_SRC_ALU16:
      begin
        reg_din16 = alu16_out;
        reg_din16we = 1;
      end
    default:
      begin
        reg_din16 = 16'bX;
        reg_din16we = 0;
      end
  endcase
end

always @(*)
begin
  case (uc_din16_sel)
    VAL_DIN16_SEL_IR54RP1:
      reg_din16sel = IR1[5:4];   
    VAL_DIN16_SEL_IR54RP2:
      reg_din16sel = 4 + IR1[5:4];   
    VAL_DIN16_SEL_SP:
      reg_din16sel = 7;
    VAL_DIN16_SEL_HL:
      reg_din16sel = 2;
    VAL_DIN16_SEL_DE:
      reg_din16sel = 1;
    VAL_DIN16_SEL_BC:
      reg_din16sel = 0;
    default:
      reg_din16sel = 4'bX;
  endcase
end

always @(*)
begin
  case (uc_dout16_sel)
    VAL_DOUT16_SEL_BC: reg_dout16sel = 0;
    VAL_DOUT16_SEL_DE: reg_dout16sel = 1;
    VAL_DOUT16_SEL_HL: reg_dout16sel = 2;
    VAL_DOUT16_SEL_SP: reg_dout16sel = 7;
    VAL_DOUT16_SEL_IR54RP: reg_dout16sel = IR1[5:4];
    VAL_DOUT16_SEL_IR54RP2: reg_dout16sel = 4 + IR1[5:4];
    default: reg_dout16sel = 3'bX;
  endcase
end

always @(*)
begin
  case (uc_flags_source)
    VAL_FLAGS_SOURCE_ALU8:
      begin
        reg_flags_in = alu8_flags_out;
        reg_flags_we = 1;      
      end
    VAL_FLAGS_SOURCE_ALU16:
      begin
        reg_flags_in = alu16_flags_out;
        reg_flags_we = 1;      
      end
    VAL_FLAGS_SOURCE_ALU_BLK:
      begin
        reg_flags_in = alu_blk_flags_out;
        reg_flags_we = 1;      
      end
    default:
      begin
        reg_flags_in = 8'bX;
        reg_flags_we = 0;
      end
  endcase
end

always @(*)
begin
  case (uc_ram_addr_sel)
    VAL_ADDR_SEL_IP: ram_addr = IP;
    VAL_ADDR_SEL_DOUT16: 
      if (xy_sel == XY_SELECT_HL || uc_dout16_sel != VAL_DOUT16_SEL_HL)
        ram_addr = reg_dout16;
      else
        // special handling for (ix+d) and (iy+d)
        ram_addr = $signed(reg_dout16) + $signed(xy_off);
    VAL_ADDR_SEL_ALU16: ram_addr = alu16_out;
    VAL_ADDR_SEL_TMP: ram_addr = TMP;
    VAL_ADDR_SEL_TMP_P1: ram_addr = TMP + 1;
    default: ram_addr = 16'bX;
  endcase
end

always @(posedge clk)
begin
  if (reset)
    IP <= 0;
  else if (uc_ip_op == VAL_INC_IP)
    IP <= IP + 1;
  else if (uc_ip_op == VAL_IP_FROM_TMP)
    IP <= TMP;
  else if (uc_ip_op == VAL_IP_FROM_REL_TMP)
    IP <= $signed(IP) + $signed(TMP[7:0]);
  else if (uc_ip_op == VAL_IP_FROM_RST)
    IP <= IR1[5:3] * 8;
end
    

always @(posedge clk)
begin
  case (uc_read_target)
    VAL_RD_IR: IR1 <= ram_dout;
    VAL_RD_TMP_LO: TMP[7:0] = ram_dout;
    VAL_RD_TMP_HI: TMP[15:8] = ram_dout;
    VAL_RD_TMP2_LO: TMP2[7:0] = ram_dout;
    VAL_RD_TMP2_HI: TMP2[15:8] = ram_dout;
    VAL_RD_TMP_FROM_DOUT16: TMP = reg_dout16; 
    VAL_RD_TMP2_FROM_DOUT16: TMP2 = reg_dout16; 
    VAL_RD_XY_OFF: xy_off = ram_dout;
    VAL_RD_TMP_LO_FROM_IO: TMP[7:0] = io_dout;
  endcase
end

/*
always @(uc_read_target, ram_dout, reg_dout16)
begin
  case (uc_read_target)

  endcase
end
*/

assign ir1_out = IR1;

always @(posedge clk)
begin
  halt <= uc_command == VAL_HALT;
end


assign alu8_ain = reg_aout8;
assign alu8_flags_in = reg_flags_out;

always @(*)
begin
  case (uc_alu8_source)
    VAL_ALU8_SRC_RAM: alu8_arg = ram_dout;
    VAL_ALU8_SRC_DOUT8: alu8_arg = reg_dout8;
    VAL_ALU8_SRC_TMP_LO: alu8_arg = TMP[7:0];
    VAL_ALU8_SRC_IO: alu8_arg = io_dout;
    default:
      alu8_arg = 8'bX;
  endcase
end

always @(*)
begin
  case (uc_alu8_op)
    VAL_ALU8_OP_IP543: alu8_op = IR1[5:3];
    VAL_ALU8_OP_IP543B: alu8_op = 8 + IR1[5:3]; 
    VAL_ALU8_OP_IP543_CBROT: alu8_op = 16 + IR1[5:3]; 
    VAL_ALU8_OP_INC: alu8_op = 24;
    VAL_ALU8_OP_DEC: alu8_op = 25;
    VAL_ALU8_OP_BIT: alu8_op = 26;
    VAL_ALU8_OP_RES: alu8_op = 27;
    VAL_ALU8_OP_SET: alu8_op = 28;
    VAL_ALU8_OP_IN: alu8_op = 29;
    VAL_ALU8_OP_NEG: alu8_op = 30;
    VAL_ALU8_OP_RRD_1: alu8_op = 31;
    VAL_ALU8_OP_RRD_2: alu8_op = 32;
    VAL_ALU8_OP_RLD_1: alu8_op = 33;
    VAL_ALU8_OP_RLD_2: alu8_op = 34;
    default:
      alu8_op = 5'bX;
  endcase
end


assign alu16_op = uc_alu16_op;

always @(*)
begin
  case (uc_ram_wr_sel)
    VAL_IO_WR_DOUT8:
      begin
        io_din = reg_dout8;
        io_we = 1;
      end
    VAL_IO_WR_TMP_LO:
      begin
        io_din = TMP[7:0];
        io_we = 1;
      end
    VAL_IO_WR_0:
      begin
        io_din = 0;
        io_we = 1;
      end
    default:
      begin
        io_din = 8'bX;
        io_we = 0;
      end
  endcase
end

always @(*)
begin
  case (uc_ram_addr_sel)
    VAL_IO_ADDR_SEL_DOUT8:
      io_addr = reg_dout8;
    VAL_IO_ADDR_SEL_TMP_LO:
      io_addr = TMP[7:0];
    default:
      io_addr = 8'bX;
  endcase
end

always @(*)
begin
  case (uc_xy_sel)
    VAL_XY_SEL_CLEAR:
      xy_sel = XY_SELECT_HL;
    VAL_XY_SEL_IX:
      xy_sel = XY_SELECT_IX;
    VAL_XY_SEL_IY:
      xy_sel = XY_SELECT_IY;
  endcase
end

endmodule