`timescale 1ns / 1ps

module z80_tb(

    );

`include "ucode_consts.vh"

parameter period = 25;
    
reg clk;
reg reset_external;
wire [UCODE_ADDR_LENGTH-1:0] ucode_addr;
wire [UCODE_LENGTH-1:0] ucode;
wire [7:0] IR;

z80 dut(
  .clk(clk),
  .reset_external(reset_external),
  .halt(halt),
  .ucode_addr_out(ucode_addr),
  .ucode_out(ucode),
  .ir1_out(IR)
  );
  
initial begin
  clk = 0;
  reset_external = 1;
  #60;
  reset_external = 0;
end
    
always
begin
  #period;
  clk = !clk;
  if (!reset_external && halt)
  begin
    $finish;
  end
end

initial
begin 
  #1000;
  $finish;
end

endmodule
