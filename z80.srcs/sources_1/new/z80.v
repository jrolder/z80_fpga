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
    
    
wire [UCODE_ADDR_LENGTH-1:0] ucode_addr;
wire [UCODE_LENGTH-1:0] ucode;
    
ucode_rom ucode_rom(
  .clk(clk),
  .reset(reset),
  .ucode_addr(ucode_addr),
  .ucode(ucode)
  );

assign ucode_addr = ucode[UCODE_ADDR_LENGTH-1:0];
assign ucode_out = ucode;
assign ucode_addr_out = ucode_addr;

`include "ucode_signals.vh"
/*
wire uc_ip_to_addr;
assign uc_ip_to_addr = ucode[BIT_IP_TO_ADDR];
assign uc_rd = ucode[BIT_RD];
assign uc_decode1 = ucode[BIT_DECODE1];
assign uc_inc_ip = ucode[BIT_INC_IP];
assign uc_rd_ir1 = ucode[BIT_RD_IR1];
*/

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
    

reg [7:0] IR1;

always @(uc_rd_ir1, ram_dout)
begin
  if (uc_rd_ir1)
    IR1 = ram_dout;
end

assign ir1_out = IR1;

endmodule