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
      `include "ucode.vh"
      default: ucode <= 7;
    endcase
end


endmodule
