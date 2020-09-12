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
    
integer i;
reg [7:0] char;
    
always
begin
  #period;
  clk = !clk;
  if (!reset_external && halt)
  begin
    $finish;
  end
`ifdef DONT_COMPILE
  if (clk && dut.uc_command == VAL_BDOS)
  begin
    $display("bdos called DE: %H", dut.registers.DE);
    $display("bdos called C: %H", dut.registers.BC[7:0]);
    case (dut.registers.BC[7:0])
        9:
          begin
            // $display("bdos! %H %H", dut.registers.DE, dut.regiters.BC[7:0]);
    
            i = dut.registers.DE;
            while (dut.sys_ram.mem[i])
            begin
              char = dut.sys_ram.mem[i];
              $write("%c", char);
              i = i+1;
            end
          end
    endcase
  end
`endif
end

initial
begin 
  #1000000;
  $finish;
end

endmodule
