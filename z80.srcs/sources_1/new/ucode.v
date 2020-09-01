`timescale 1ns / 1ps

module ucode_rom(
    clk,
    reset,
    ucode_addr,
    ucode
    );
    
`include "ucode_consts.vh"

input wire clk;
input wire reset;
input wire [UCODE_ADDR_LENGTH-1:0] ucode_addr;
output reg [UCODE_LENGTH-1:0] ucode;
    
always @(posedge clk)
begin
  if (reset)
    ucode <= 0;
  else
    case (ucode_addr)
      0: ucode <= MASK_IP_TO_ADDR | MASK_RD | MASK_INC_IP | MASK_RD_IR1 | MASK_DECODE1 | 5;
      5: ucode <= 6;
      6: ucode <= 0;
      default: ucode <= 7;
    endcase
end


endmodule
