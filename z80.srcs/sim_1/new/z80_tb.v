`timescale 1ns / 1ps

module z80_tb(

    );
    
parameter period = 25;
    
reg clk;
reg reset_external;
wire [11:0] ucode_addr;
wire [15:0] ucode;

z80 dut(
  .clk(clk),
  .reset_external(reset_external),
  .ucode_addr_out(ucode_addr),
  .ucode_out(ucode)
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
end

initial
begin 
  #1000;
  $finish;
end

endmodule