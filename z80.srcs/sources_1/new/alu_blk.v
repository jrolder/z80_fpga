`timescale 1ns / 1ps

// block operation flags calculation
// see "undocumented z80 documented" for background


module alu_blk(
    input wire clk,
    input wire reset,
    input wire [15:0] reg16,
    input wire [7:0] reg8,
    input wire [7:0] mem8,
    input wire [0:0] op,
    input wire [0:0] latch_op,
    input wire [7:0] flags_in,
    output reg [7:0] flags_out
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
      endcase
    end
end
    
reg [7:0] n;    
    
always @(*)
begin
  case (op)
  VAL_BLK_OP_LD: 
    begin
      // inputs: latched data, live reg16 containing BC, live reg8 containing A
      n = data + reg8;
      flags_out = {flag_s, flag_z, n[1], 1'b0, n[3], reg16 != 0, 1'b0, flag_c};
    end
  default:
    begin
      flags_out = 8'bX;
    end
  endcase
end

endmodule
