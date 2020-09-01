`timescale 1ns / 1ps



module z80(
    input wire clk,
    input wire reset_external,
    output reg [15:0] ucode
    );
    
wire reset;
    
sync_reset sync_reset(
  .reset_external(reset_external),
  .clk(clk),
  .reset(reset)
  );
    
    
wire [11:0] ucode_addr;
wire [15:0] ucode;
    
ucode_rom ucode_rom(
  .clk(clk),
  .reset(reset),
  .ucode_addr(ucode_addr),
  .ucode(ucode)
  );

assign ucode_addr = ucode[11:0];

endmodule