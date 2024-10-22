`timescale 1ns / 1ps

module alu8(
    input wire [7:0] alu8_ain,
    output reg [7:0] alu8_out,
    input wire [5:0] alu8_op,
    input wire [7:0] alu8_arg,
    input wire [7:0] alu8_flags_in,
    output reg [7:0] alu8_flags_out,
    input wire [2:0] alu8_bit_sel
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
reg cf_out, hf_out;
reg bit_set;
    
task daa_diff;
  input [7:0]a;
  input cf, hf, nf;
  output [7:0] daa_diff;
  output cf_out, hf_out;
  reg [3:0] hi;
  reg [3:0] lo;
  begin
    hi = a[7:4];
    lo = a[3:0];
    if (lo < 10) 
      // lo is 0-9
      begin
        if (cf)
          begin
            if (hf)
              begin
                cf_out = 1;
                daa_diff = 8'h66;
              end
            else
              begin
                cf_out = 1;
                daa_diff = 8'h60;
              end
          end
        else
          // cf = 0
          begin
            if (hf)
              begin
                if (hi < 10)
                  begin
                    cf_out = 0;
                    daa_diff = 8'h06;
                  end
                else 
                  begin
                    cf_out = 1;
                    daa_diff = 8'h66;
                  end
              end
            else
              begin
                if (hi < 10)
                  begin
                    cf_out = 0;
                    daa_diff = 8'h00;
                  end
                else 
                  begin
                    cf_out = 1;
                    daa_diff = 8'h60;
                  end
              end
          end
      end
    else
      // lo is a-f
      begin
        if (cf)
          begin
            cf_out = 1;
            daa_diff = 8'h66;
          end
        else
          begin
            if (hi < 9)
              begin
                cf_out = 0;
                daa_diff = 8'h06;
              end  
            else
              begin
                cf_out = 1;
                daa_diff = 8'h66;
              end
          end
      end
    if (nf) 
        hf_out = hf && (lo < 6); 
    else
        hf_out = lo >= 10;
  end
endtask
    
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
  8: // rlca
    begin
      alu8_out = {alu8_ain[6:0], alu8_ain[7]};
      alu8_flags_out = {flag_s, flag_z, alu8_out[5], 1'b0, alu8_out[3], flag_pv, 1'b0, alu8_ain[7]};
    end
  9: // rrca
    begin
      alu8_out = {alu8_ain[0], alu8_ain[7:1]};
      alu8_flags_out = {flag_s, flag_z, alu8_out[5], 1'b0, alu8_out[3], flag_pv, 1'b0, alu8_ain[0]};
    end
  10: // rla
    begin
      alu8_out = {alu8_ain[6:0], flag_c};
      alu8_flags_out = {flag_s, flag_z, alu8_out[5], 1'b0, alu8_out[3], flag_pv, 1'b0, alu8_ain[7]};
    end
  11: // rra
    begin
      alu8_out = {flag_c, alu8_ain[7:1]};
      alu8_flags_out = {flag_s, flag_z, alu8_out[5], 1'b0, alu8_out[3], flag_pv, 1'b0, alu8_ain[0]};
    end
  12: // daa
    begin
      daa_diff(alu8_ain, flag_c, flag_h, flag_n, tmp8, cf_out, hf_out);
      if (flag_n)
        alu8_out = alu8_ain - tmp8;
      else
        alu8_out = alu8_ain + tmp8;
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], hf_out, alu8_out[3], !(^alu8_out), flag_n, cf_out};
    end
  13: // cpl
    begin
      alu8_out = ~alu8_ain;
      alu8_flags_out = {flag_s, flag_z, alu8_out[5], 1'b1, alu8_out[3], flag_pv, 1'b1, flag_c};
    end
  14: // scf
    begin
      alu8_out = alu8_ain;
      alu8_flags_out = {flag_s, flag_z, alu8_ain[5], 1'b0, alu8_ain[3], flag_pv, 1'b0, 1'b1};
    end
  15: // ccf
    begin
      alu8_out = alu8_ain;
      alu8_flags_out = {flag_s, flag_z, alu8_ain[5], flag_c, alu8_ain[3], flag_pv, 1'b0, !flag_c};
    end
  16: // rlc
    begin
      alu8_out = {alu8_arg[6:0], alu8_arg[7]};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[7]};
    end
  17: // rrc
    begin
      alu8_out = {alu8_arg[0], alu8_arg[7:1]};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[0]};
    end
  18: // rl
    begin
      alu8_out = {alu8_arg[6:0], flag_c};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[7]};
    end
  19: // rr
    begin
      alu8_out = {flag_c, alu8_arg[7:1]};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[0]};
    end    
  20: // sla
    begin
      alu8_out = {alu8_arg[6:0], 1'b0};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[7]};
    end
  21: // sra
    begin
      alu8_out = {alu8_arg[7], alu8_arg[7:1]};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[0]};
    end
  22: // sll
    begin
      alu8_out = {alu8_arg[6:0], 1'b1};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[7]};
    end
  23: // srl
    begin
      alu8_out = {1'b0, alu8_arg[7:1]};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, alu8_arg[0]};
    end
  24: // inc
    begin
      tmp9 = alu8_arg + 1;
      tmp8 = alu8_arg[6:0] + 1;
      tmp5 = alu8_arg[3:0] + 1;
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], alu8_arg == 8'h7f, 1'b0, flag_c};
    end
  25: // dec
    begin
      tmp9 = alu8_arg - 1;
      tmp8 = alu8_arg[6:0] - 1;
      tmp5 = alu8_arg[3:0] - 1;
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], alu8_arg == 8'h80, 1'b1, flag_c};
    end
  26: // (test) bit
    begin
      bit_set = (alu8_arg & (1 << alu8_bit_sel)) != 0;
      alu8_out = alu8_arg;
      alu8_flags_out = {
        (alu8_bit_sel == 7) && bit_set,     // SF flag Set if n = 7 and tested bit is set.
        !bit_set,                           // ZF flag Set if the tested bit is reset.
        alu8_arg[5],                        // YF flag Set if n = 5 and tested bit is set.
        1'b1,                               // HF flag Always set.
        alu8_arg[3],                        // XF flag Set if n = 3 and tested bit is set.
        !bit_set,                           // PF flag Set just like ZF flag.
        1'b0,                               // NF flag Always reset.
        flag_c                              // CF flag Unchanged
        };                            
    end
  27: // res(et) bit
    begin
      alu8_out = alu8_arg & ~(1 << alu8_bit_sel);
      alu8_flags_out = alu8_flags_in; 
    end
  28: // set bit
    begin
      alu8_out = alu8_arg | (1 << alu8_bit_sel);
      alu8_flags_out = alu8_flags_in; 
    end
  29: // evaluate in value
    begin
      alu8_flags_out = {alu8_arg[7], alu8_arg == 0, alu8_arg[5], 1'b0, alu8_arg[3],!(^alu8_arg), 1'b0, flag_c};
    end
  30: // neg
    begin
      tmp9 = 0 - alu8_ain;
      tmp8 = 0 - alu8_ain[6:0];
      tmp5 = 0 - alu8_ain[3:0];
      alu8_out = tmp9[7:0];
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], tmp5[4], alu8_out[3], tmp9[8] ^ tmp8[7], 1'b1, tmp9[8]};
    end
  31: // rrd part 1: (hl) result 
    begin
      alu8_out = {alu8_ain[3:0], alu8_arg[7:4]};
      alu8_flags_out = alu8_flags_in;
    end
  32: // rrd part 2: A result 
    begin
      alu8_out = {alu8_ain[7:4], alu8_arg[3:0]};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, flag_c};
    end
  33: // rld part 1: (hl) result 
    begin
      alu8_out = {alu8_arg[3:0], alu8_ain[3:0]};
      alu8_flags_out = alu8_flags_in;
    end
  34: // rld part 2: A result 
    begin
      alu8_out = {alu8_ain[7:4], alu8_arg[7:4]};
      alu8_flags_out = {alu8_out[7], alu8_out == 0, alu8_out[5], 1'b0, alu8_out[3], !(^alu8_out), 1'b0, flag_c};
    end
  35: // bit flags fixup: XF and YF from ram addr 
    begin
      alu8_out = 8'bX;
      alu8_flags_out = {flag_s, flag_z, alu8_arg[5], flag_h, alu8_arg[3], flag_pv, flag_n, flag_c};
    end
  default:
    begin
      alu8_out = 8'bX;
      alu8_flags_out = 8'bX;
    end
  endcase  
end
    
endmodule
