`timescale 1ns / 1ps



module alu16(
    input wire [15:0] alu16_arg1,
    input wire [15:0] alu16_arg2,
    output reg [15:0] alu16_out,
    input wire [2:0]  alu16_op,
    input wire [7:0]  alu16_flags_in,
    output reg [7:0]  alu16_flags_out
    );

`include "ucode_consts.vh"

parameter FLAG_S = 7; // sign flag
parameter FLAG_Z = 6; // zero flag
parameter FLAG_F5 = 5; // bit 5
parameter FLAG_H = 4; // half carry flag
parameter FLAG_F3 = 3; // bit 3
parameter FLAG_PV = 2; // parity/overflow
parameter FLAG_N = 1;  // op was sub
parameter FLAG_C = 0; // carry

wire flag_s, flag_z, flag_f5, flag_h, flag_f3, flag_pv, flag_n, flag_c;
assign flag_s = alu16_flags_in[FLAG_S];
assign flag_z = alu16_flags_in[FLAG_Z];
assign flag_f5 = alu16_flags_in[FLAG_F5];
assign flag_h = alu16_flags_in[FLAG_H];
assign flag_f3 = alu16_flags_in[FLAG_F3];
assign flag_pv = alu16_flags_in[FLAG_PV];
assign flag_n = alu16_flags_in[FLAG_N];
assign flag_c = alu16_flags_in[FLAG_C];

reg [12:0] tmp13;
reg [16:0] tmp17;

always @(*)
begin
  case (alu16_op)
    VAL_ALU16_OP_INC: // inc
      begin
        alu16_out = alu16_arg1 + 1;
        alu16_flags_out = alu16_flags_in;
      end
    VAL_ALU16_OP_DEC: // dec
      begin
        alu16_out = alu16_arg1 - 1;
        alu16_flags_out = alu16_flags_in;
      end    
    VAL_ALU16_OP_ADD: // add
      begin 
        tmp17 = alu16_arg1 + alu16_arg2;
        tmp13 = alu16_arg1[11:0] + alu16_arg2[11:0];
        alu16_out = tmp17[15:0];
        alu16_flags_out = {flag_s, flag_z, flag_f5, tmp13[12], flag_f3, flag_pv, 1'b0, tmp17[16]};
      end
    default:
      begin
        alu16_out = 16'bX;
        alu16_flags_out = 8'bX;
      end
  endcase
end

endmodule
