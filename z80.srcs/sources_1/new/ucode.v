`timescale 1ns / 1ps

module ucode_rom(
    input wire clk,
    input wire reset,
    input wire [11:0] ucode_addr,
    output reg [15:0] ucode
    );
    
    
    
always @(posedge clk)
begin
  if (reset)
    ucode <= 0;
  else
    case (ucode_addr)
      0: ucode <= 5;
      5: ucode <= 6;
      6: ucode <= 0;
      default: ucode <= 7;
    endcase
end


endmodule
