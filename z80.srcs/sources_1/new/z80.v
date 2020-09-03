`timescale 1ns / 1ps



module z80(
    clk,
    reset_external,
    ucode_addr_out,
    ucode_out,
    ir1_out
    );

`include "ucode_consts.vh"
    
input wire clk;
input wire reset_external;
output wire [UCODE_ADDR_LENGTH-1:0] ucode_addr_out;
output wire [UCODE_LENGTH-1:0] ucode_out;
output wire [7:0] ir1_out;
    
wire reset;
    
sync_reset sync_reset(
  .reset_external(reset_external),
  .clk(clk),
  .reset(reset)
  );
    
    
reg [UCODE_ADDR_LENGTH-1:0] ucode_addr;
wire [UCODE_LENGTH-1:0] ucode;
    
ucode_rom ucode_rom(
  .clk(clk),
  .reset(reset),
  .ucode_addr(ucode_addr),
  .ucode(ucode)
  );

assign ucode_out = ucode;
assign ucode_addr_out = ucode_addr;

`include "ucode_signals.vh"

wire [UCODE_ADDR_LENGTH-1:0] decode1_out;
reg [7:0] IR1;

decode1_rom decode1_rom (
  .opcode(IR1),
  .uc_addr(decode1_out)
  );
  
  
always @(*)
begin
  if (uc_decode == VAL_DECODE1)
    ucode_addr = decode1_out;
  else
    ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
end

reg [15:0] ram_addr;
reg ram_we;
reg [7:0] ram_din;
wire [7:0] ram_dout;
    
sys_ram sys_ram(
  .addr(ram_addr),
  .we(ram_we),
  .clk(clk),
  .din(ram_din),
  .dout(ram_dout));

initial
begin
  ram_we = 0;
end

reg [15:0] IP;

always @(*)
begin
  if (uc_ip_to_addr)
    ram_addr = IP;
  else
    ram_addr = 16'haffe;
end

always @(posedge clk)
begin
  if (reset)
    IP <= 0;
  else if (uc_inc_ip)
    IP <= IP + 1;
end
    



always @(uc_rd_ir1, ram_dout)
begin
  if (uc_rd_ir1)
    IR1 = ram_dout;
end

assign ir1_out = IR1;

endmodule