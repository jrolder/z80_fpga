`timescale 1ns / 1ps

module sync_reset(
    input wire reset_external,
    input wire clk,
    output reg reset
    );
    
always @(posedge clk, posedge reset_external)
begin
  if (reset_external)
    reset <= 1;
  else
    reset <= reset_external;
end

endmodule
