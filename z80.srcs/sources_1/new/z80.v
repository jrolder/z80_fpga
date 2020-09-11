`timescale 1ns / 1ps



module z80(
    clk,
    reset_external,
    halt,
    ucode_addr_out,
    ucode_out,
    ir1_out,
    bc_out
    );

`include "ucode_consts.vh"
    
input wire clk;
input wire reset_external;
output reg halt;
output wire [UCODE_ADDR_LENGTH-1:0] ucode_addr_out;
output wire [UCODE_LENGTH-1:0] ucode_out;
output wire [7:0] ir1_out;
output wire [15:0] bc_out;
    
wire reset;
    
sync_reset sync_reset(
  .reset_external(reset_external),
  .clk(clk),
  .reset(reset)
  );
    
    
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

assign ucode_out = ucode;
assign ucode_addr_out = ucode_addr;

`include "ucode_signals.vh"

wire [UCODE_ADDR_LENGTH-1:0] decode1_out;
reg [7:0] IR1;
reg [7:0] ARG1;
reg [7:0] ARG2;

decode1_rom decode1_rom (
  .opcode(IR1),
  .uc_addr(decode1_out)
  );
  
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
    VAL_GOTO_NOW: 
      ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
    VAL_GOTO_NCC:
      begin
        if (check_condition(IR1[5:3], reg_flags_out))
          ucode_addr = last_ucode_addr + 1;
        else
          ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
      end
    default:
      ucode_addr = last_ucode_addr + 1;
  endcase
end

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

always @(*)
begin
  case (uc_ram_wr_sel)
    VAL_RAM_WR_DOUT8:
      begin
        ram_din = reg_dout8;
        ram_we = 1;
      end
    VAL_RAM_WR_ARG1:
      begin
        ram_din = ARG1;
        ram_we = 1;
      end
    VAL_RAM_WR_ARG2:
      begin
        ram_din = ARG2;
        ram_we = 1;
      end
    default:
      begin
        ram_din = 8'bX;
        ram_we = 0;
      end
  endcase
end


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
  .aout8(reg_aout8)
  );
  
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
    VAL_DIN8_DST_IR543: 
      reg_din8sel = IR1[5:3];
    VAL_DIN8_DST_A:
      reg_din8sel = 7;
    default:
      reg_din8sel = 4'bX;
  endcase
end

always @(*)
begin
  case (uc_dout8_sel)
    VAL_DOUT8_SEL_IR210: reg_dout8sel = IR1[2:0];
    default:
      reg_dout8sel = 4'bX;
  endcase
end

always @(*)
begin
  case (uc_din16_source)
    VAL_DIN16_SRC_ARG12: 
      begin
        reg_din16 = {ARG2, ARG1};
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
    default:
      reg_din16sel = 4'bX;
  endcase
end

always @(*)
begin
  case (uc_dout16_sel)
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
    default:
      begin
        reg_flags_in = 8'bX;
        reg_flags_we = 0;
      end
  endcase
end

reg [15:0] IP;

always @(*)
begin
  case (uc_ram_addr_sel)
    VAL_ADDR_SEL_IP: ram_addr = IP;
    VAL_ADDR_SEL_DOUT16: ram_addr = reg_dout16;
    VAL_ADDR_SEL_ALU16: ram_addr = alu16_out;
    default: ram_addr = 16'bX;
  endcase
end

always @(posedge clk)
begin
  if (reset)
    IP <= 0;
  else if (uc_ip_op == VAL_INC_IP)
    IP <= IP + 1;
  else if (uc_ip_op == VAL_IP_FROM_ARG21)
    IP <= {ARG2, ARG1};
end
    



always @(uc_read_target, ram_dout)
begin
  case (uc_read_target)
    VAL_RD_IR: IR1 = ram_dout;
    VAL_RD_ARG1: ARG1 = ram_dout;
    VAL_RD_ARG2: ARG2 = ram_dout;
    VAL_RD_DOUT16:
      begin
        ARG2 = reg_dout16[15:8];
        ARG1 = reg_dout16[7:0];
      end
  endcase
end

assign ir1_out = IR1;

always @(posedge clk, posedge reset)
begin
  halt <= uc_command == VAL_HALT;
end

wire [7:0] alu8_ain;
wire [7:0] alu8_out;
reg [4:0] alu8_op;
reg [7:0] alu8_arg;
wire [7:0] alu8_flags_in;
wire [7:0] alu8_flags_out;

alu8 alu8 (
  .alu8_ain(alu8_ain),
  .alu8_out(alu8_out),
  .alu8_op(alu8_op),
  .alu8_arg(alu8_arg),
  .alu8_flags_in(alu8_flags_in),
  .alu8_flags_out(alu8_flags_out)
  );

assign alu8_ain = reg_aout8;
assign alu8_flags_in = reg_flags_out;

always @(*)
begin
  case (uc_alu8_source)
    VAL_ALU8_SRC_RAM: alu8_arg = ram_dout;
    VAL_ALU8_SRC_DOUT8: alu8_arg = reg_dout8;
    default:
      alu8_arg = 8'bX;
  endcase
end

always @(*)
begin
  case (uc_alu8_op)
    VAL_ALU8_OP_IP543: alu8_op = IR1[5:3];
    VAL_ALU8_OP_SCF: alu8_op = 16;
    VAL_ALU8_OP_CCF: alu8_op = 17;
    default:
      alu8_op = 5'bX;
  endcase
end
    
wire [15:0] alu16_out;
wire [7:0] alu16_flags_out;
wire [2:0] alu16_op;

alu16 alu16 (
  .alu16_arg1(reg_dout16),
  .alu16_arg2({ARG1,ARG2}),
  .alu16_out(alu16_out),
  .alu16_op(alu16_op),
  .alu16_flags_in(reg_flags_out),
  .alu16_flags_out(alu16_flags_out)
);

assign alu16_op = uc_alu16_op;


endmodule