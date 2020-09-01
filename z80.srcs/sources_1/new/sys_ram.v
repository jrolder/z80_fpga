`timescale 1ns / 1ps

module sys_ram(
    input [15:0] addr,
    input we,
    input clk,
    input [7:0] din,
    output reg [7:0] dout
    );
    
 reg [7:0] mem [127:0];

initial 
begin
  mem[0] = 0;
  mem[1] = 8'hc3;
  mem[2] = 8'hf0;
  mem[3] = 8'he0;
end

always @(posedge clk) begin
    if (we)
        mem[addr] <= din;
end

always @(*)
begin
    dout = mem[addr];
end

endmodule
