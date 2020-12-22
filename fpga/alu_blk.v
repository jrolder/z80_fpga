`timescale 1ns / 1ps

// block operation flags calculation
// see "undocumented z80 documented" for background


module alu_blk(
    input wire clk,
    input wire reset,
    input wire [15:0] reg16,
    input wire [7:0] reg8,
    input wire [7:0] mem8,
    input wire [7:0] io8,
    input wire [2:0] op,
    input wire [1:0] latch_op,
    input wire [7:0] flags_in,
    output reg [7:0] flags_out,
    output reg do_loop
    );

parameter FLAG_S = 7; // sign flag
parameter FLAG_Z = 6; // zero flag
parameter FLAG_F5 = 5; // bit 5
parameter FLAG_H = 4; // half carry flag
parameter FLAG_F3 = 3; // bit 3
parameter FLAG_PV = 2; // parity/overflow
parameter FLAG_N = 1;  // op was sub
parameter FLAG_C = 0; // carry

wire flag_s, flag_z, flag_f5, flag_h, flag_f3, flag_pv, flag_n, flag_c;
assign flag_s = flags_in[FLAG_S];
assign flag_z = flags_in[FLAG_Z];
assign flag_f5 = flags_in[FLAG_F5];
assign flag_h = flags_in[FLAG_H];
assign flag_f3 = flags_in[FLAG_F3];
assign flag_pv = flags_in[FLAG_PV];
assign flag_n = flags_in[FLAG_N];
assign flag_c = flags_in[FLAG_C];

reg [7:0] data; 
reg [4:0] tmp5;
reg [7:0] tmp8;
reg [8:0] tmp9;
reg HF;

`include "ucode_consts.vh"
  
always @(posedge clk)
begin
  if (reset)
      begin
        data <= 8'h00;
      end
  else
    begin     
      case (latch_op)
      VAL_BLK_LATCH_DATA:
        data <= mem8;
      VAL_BLK_LATCH_IO:
        data <= io8;
      endcase
    end
end
    
reg [7:0] n;    
reg [8:0] k;
reg p;    
    
always @(*)
begin
  case (op)
  VAL_BLK_OP_LD: 
    begin
      // inputs: latched data, live reg16 containing BC, live reg8 containing A
      n = data + reg8;
      flags_out = {flag_s, flag_z, n[1], 1'b0, n[3], reg16 != 0, 1'b0, flag_c};
      do_loop = flags_out[FLAG_PV];
    end
  VAL_BLK_OP_CP: 
    begin
      // inputs: latched data, live reg16 containing BC, live reg8 containing A
      tmp9 = reg8 - data;
      tmp8 = reg8[6:0] - data[6:0];
      tmp5 = reg8[3:0] - data[3:0];
      HF = tmp5[4];
      n = reg8 - data - HF;
      // flag_s, flag_z, flag_f5, flag_h, flag_f3, flag_pv, flag_n, flag_c
      flags_out = {tmp9[7], tmp9[7:0] == 0, n[1], HF, n[3], reg16 != 0, 1'b1, flag_c};
      do_loop = flags_out[FLAG_PV] && !flags_out[FLAG_Z];
    end
  VAL_BLK_OP_OUT: 
    begin
      // inputs: latched data, live reg16 containing BC, live reg8 containing L
      // tricky: flags from dec B already in flags
      k = data + reg8;
      p = !(^((k[7:0] & 8'b111) ^ reg16[15:8]));
      // flag_s, flag_z, flag_f5, flag_h, flag_f3, flag_pv, flag_n, flag_c
      flags_out = {flag_s, flag_z, flag_f5, k[8], flag_f3, p, data[7], k[8]};
      do_loop = !flags_out[FLAG_Z];
    end
  VAL_BLK_OP_INI: 
    begin
      // inputs: latched data, live reg16 containing BC, live reg8 containing L
      // tricky: flags from dec B already in flags
      k = data + ((reg16[7:0] + 1) & 8'b11111111);
      p = !(^((k[7:0] & 8'b111) ^ reg16[15:8]));
      // flag_s, flag_z, flag_f5, flag_h, flag_f3, flag_pv, flag_n, flag_c
      flags_out = {flag_s, flag_z, flag_f5, k[8], flag_f3, p, data[7], k[8]};
      do_loop = !flags_out[FLAG_Z];
    end
  VAL_BLK_OP_IND: 
    begin
      // inputs: latched data, live reg16 containing BC, live reg8 containing L
      // tricky: flags from dec B already in flags
      k = data + ((reg16[7:0] - 1) & 8'b11111111);
      p = !(^((k[7:0] & 8'b111) ^ reg16[15:8]));
      // flag_s, flag_z, flag_f5, flag_h, flag_f3, flag_pv, flag_n, flag_c
      flags_out = {flag_s, flag_z, flag_f5, k[8], flag_f3, p, data[7], k[8]};
      do_loop = !flags_out[FLAG_Z];
    end
  default:
    begin
      flags_out = 8'bX;
    end
  endcase
end

endmodule
