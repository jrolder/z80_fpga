`timescale 1ns / 1ps

module ucode_rom(
    clk,
    reset,
    ucode_addr,
    last_ucode_addr,
    ucode
    );
    
`include "ucode_consts.vh"

input wire clk;
input wire reset;
input wire [UCODE_ADDR_LENGTH-1:0] ucode_addr;
output reg [UCODE_ADDR_LENGTH-1:0] last_ucode_addr;
output reg [UCODE_LENGTH-1:0] ucode;
    
always @(posedge clk)
begin
  if (reset)
    begin
      ucode <= 0;
      last_ucode_addr <= 0;
    end
  else
    begin
      last_ucode_addr <= ucode_addr;
      case (ucode_addr)
        `include "ucode.vh"
        default: ucode <= 7;
      endcase
    end
end


endmodule
