#include <verilated.h>
#include "Vz80.h"

vluint64_t main_time = 0;

int main(int argc, char** argv)
{
  Verilated::commandArgs(argc, argv);
  Vz80 * top = new Vz80;
  top->reset_external = 1;
  top->clk = 0;
  while (!Verilated::gotFinish()) {
    // printf("%lld %04x\n", main_time, top->z80__DOT__IP);
    if (top->bdos_trap) {
      int cmd = top->z80__DOT__registers__DOT__BC & 0xff;
      int de = top->z80__DOT__registers__DOT__DE;
      // printf("  trap %02x %04x\n", cmd, de);
        switch (cmd) {
	case 2:
          printf("%c", de & 0xff);
	  break;
	case 9:
          while (top->z80__DOT__sys_ram__DOT__mem[de] != '$') {
            printf("%c", top->z80__DOT__sys_ram__DOT__mem[de]);
	    de++;
          }
	  break;
        }
    }
    if (main_time >= 25) {
      top->clk = !top->clk;
    }
    if (main_time == 100) {
      // load rom here
      top->reset_external = 0;
    }
    if (main_time >= 100) {
      if (top->halt) 
        break;
    }
    top->eval();
    main_time += 25;
  }
  top->final();
  delete top;
}
