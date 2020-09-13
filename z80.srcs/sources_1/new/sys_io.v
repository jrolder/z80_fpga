`timescale 1ns / 1ps

// placeholder IO module 


module sys_io(
    input clk,
    input [7:0] io_addr,
    output reg [7:0] io_dout,
    input [7:0] io_din,
    input io_we
    );
    
reg [7:0] io_mem [255:0];

always @(posedge clk) begin
    if (io_we)
        io_mem[io_addr] <= io_din;
end

always @(*)
begin
    io_dout = io_mem[io_addr];
end
    
endmodule
