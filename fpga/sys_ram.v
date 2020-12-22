`timescale 1ns / 1ps

module sys_ram(
    input [15:0] addr,
    input we,
    input clk,
    input [7:0] din,
    output reg [7:0] dout
    );
    
reg [7:0] mem [13000:0];

initial 
begin
  //$readmemh("ram.mem", mem, 0);
  $readmemh("zexwrap.mem", mem, 0);
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
