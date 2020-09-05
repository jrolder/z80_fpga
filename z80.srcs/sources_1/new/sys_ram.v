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
  mem[1] = 8'h06;
  mem[2] = 8'hde;
  mem[3] = 8'h48;
  mem[4] = 0;
  mem[5] = 0;

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
