`timescale 1ns / 1ps

module alu8(
    input wire [7:0] alu8_ain,
    output reg [7:0] alu8_out,
    input wire [4:0] alu8_op,
    input wire [7:0] alu8_arg,
    input wire [7:0] alu8_flags_in,
    output reg [7:0] alu8_flags_out
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
assign flag_s = alu8_flags_in[FLAG_S];
assign flag_z = alu8_flags_in[FLAG_Z];
assign flag_f5 = alu8_flags_in[FLAG_F5];
assign flag_h = alu8_flags_in[FLAG_H];
assign flag_f3 = alu8_flags_in[FLAG_F3];
assign flag_pv = alu8_flags_in[FLAG_PV];
assign flag_n = alu8_flags_in[FLAG_N];
assign flag_c = alu8_flags_in[FLAG_C];

reg [4:0] tmp5;
reg [7:0] tmp8;
reg [8:0] tmp9;
    
always @(*)
begin
  case (alu8_op)
  0: // add
    begin
      tmp9 = alu8_ain + alu8_arg;
      tmp8 = alu8_ain[6:0] + alu8_arg[6:0];
      tmp5 = alu8_ain[3:0] + alu8_arg[3:0];
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], tmp9[8] ^ tmp8[7], 1'b0, tmp9[8]};
    end
  1: // adc
    begin
      tmp9 = alu8_ain + alu8_arg + flag_c;
      tmp8 = alu8_ain[6:0] + alu8_arg[6:0] + flag_c;
      tmp5 = alu8_ain[3:0] + alu8_arg[3:0] + flag_c;
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], tmp9[8] ^ tmp8[7], 1'b0, tmp9[8]};
    end
  2: // sub
    begin
      tmp9 = alu8_ain - alu8_arg;
      tmp8 = alu8_ain[6:0] - alu8_arg[6:0];
      tmp5 = alu8_ain[3:0] - alu8_arg[3:0];
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], tmp9[8] ^ tmp8[7], 1'b1, tmp9[8]};
    end
   3: // sbc
    begin
      tmp9 = alu8_ain - alu8_arg - flag_c;
      tmp8 = alu8_ain[6:0] - alu8_arg[6:0] - flag_c;
      tmp5 = alu8_ain[3:0] - alu8_arg[3:0] - flag_c;
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], tmp9[8] ^ tmp8[7], 1'b1, tmp9[8]};
    end
   4: // and
    begin
      alu8_out = alu8_ain & alu8_arg;
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b1, alu8_out[3], !(^alu8_out), 1'b0, 1'b0};
    end
   5: // xor
    begin
      alu8_out = alu8_ain ^ alu8_arg;
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, 1'b0};
    end
   6: // or
    begin
      alu8_out = alu8_ain | alu8_arg;
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, 1'b0};
    end
  7: // cp
    begin
      tmp9 = alu8_ain - alu8_arg;
      tmp8 = alu8_ain[6:0] - alu8_arg[6:0];
      tmp5 = alu8_ain[3:0] - alu8_arg[3:0];
      alu8_out = alu8_ain;
      alu8_flags_out = {tmp9[7], tmp9[7:0] == 0, alu8_arg[5], tmp5[4], alu8_arg[3], tmp9[8] ^ tmp8[7], 1'b1, tmp9[8]};
    end
  16: // scf
    begin
      alu8_out = 8'bX;
      alu8_flags_out = {flag_s, flag_z, flag_f5, 1'b0, flag_f3, flag_pv, 1'b0, 1'b1};
    end
  17: // ccf
    begin
      alu8_out = 8'bX;
      alu8_flags_out = {flag_s, flag_z, flag_f5, flag_c, flag_f3, flag_pv, 1'b0, !flag_c};
    end
  18: // inc
    begin
      tmp9 = alu8_arg + 1;
      tmp8 = alu8_arg[6:0] + 1;
      tmp5 = alu8_arg[3:0] + 1;
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], alu8_arg == 8'h7f, 1'b0, flag_c};
    end
  19: // dec
    begin
      tmp9 = alu8_arg - 1;
      tmp8 = alu8_arg[6:0] - 1;
      tmp5 = alu8_arg[3:0] - 1;
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], alu8_arg == 8'h80, 1'b1, flag_c};
    end
  default:
    begin
      alu8_out = 8'bX;
      alu8_flags_out = 8'bX;
    end
  endcase  
end
    
endmodule
