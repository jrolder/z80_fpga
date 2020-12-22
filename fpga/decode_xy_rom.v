`timescale 1ns / 1ps

module decode_xy_rom(
    opcode,
    uc_addr
    );
    
`include "ucode_consts.vh"

input wire [7:0] opcode;
output reg [UCODE_ADDR_LENGTH-1:0] uc_addr;

always @(*)
begin
    case (opcode)
      `include "decode_xy.vh"
      default: uc_addr = 0;
    endcase
end

endmodule
