`timescale 1ns / 1ps

module registers(
    input wire clk,
    input wire reset,
    input wire [7:0] din8,
    output reg [7:0] dout8,
    input wire [3:0] din8sel,
    input wire [3:0] dout8sel,
    input wire [15:0] din16,
    output reg [15:0] dout16,
    input wire [3:0] din16sel,
    input wire [3:0] dout16sel,
    input wire [7:0] flags_in,
    output reg [7:0] flags_out,
    input wire din8we,
    input wire din16we,
    input wire flags_we,
    output reg [7:0] aout8,
    input wire [1:0] xy_sel
    );

`include "z80_consts.vh"

reg [15:0] BC;
reg [15:0] DE;
reg [15:0] HL;
reg [15:0] AF;

reg [15:0] SP;
reg [15:0] IX;
reg [15:0] IY;
reg [15:0] IR; // interrupt and refresh
    
always @(*)
begin 
  aout8 = AF[15:8];
  flags_out = AF[7:0];
end    
    
// 8sel is B, C, D, E, H, L, -, A, IXH, IXL, IYH, IYL
// 16sel is BC, DE, HL, AF, SP, IX, IY

always @(posedge clk)
begin
  if (reset)
      begin
        BC <= 16'hffff;
        DE <= 16'hffff;
        HL <= 16'hffff;
        AF <= 16'hffff;
        SP <= 16'hffff;
        IX <= 16'hffff;
        IY <= 16'hffff;
      end
  else
    begin 
      if (din8we)
      begin
        case (din8sel)
          0: BC[15:8] <= din8;
          1: BC[7:0] <= din8;
          2: DE[15:8] <= din8;
          3: DE[7:0] <= din8;
          4: 
            case (xy_sel)
              XY_SELECT_HL: HL[15:8] <= din8;
              XY_SELECT_IX: IX[15:8] <= din8;
              XY_SELECT_IY: IY[15:8] <= din8;
            endcase
          5: 
            case (xy_sel)
              XY_SELECT_HL: HL[7:0] <= din8;
              XY_SELECT_IX: IX[7:0] <= din8;
              XY_SELECT_IY: IY[7:0] <= din8;
            endcase
          7: AF[15:8] <= din8;
          8: BC[15:8] <= din8;
          9: BC[7:0] <= din8;
          10: DE[15:8] <= din8;
          11: DE[7:0] <= din8;
          12: HL[15:8] <= din8;
          13: HL[7:0] <= din8;
          15: AF[15:8] <= din8;
          16: IR[15:8] <= din8;
          17: IR[7:0] <= din8;
        endcase
      end
      else if (din16we)
          begin
            case (din16sel)
              0: BC <= din16;
              1: DE <= din16;
              2: 
                case (xy_sel)
                  XY_SELECT_HL: HL <= din16;
                  XY_SELECT_IX: IX <= din16;
                  XY_SELECT_IY: IY <= din16;
                endcase
              3: AF <= din16;
              4: BC <= din16;
              5: DE <= din16;
              6:
                case (xy_sel)
                  XY_SELECT_HL: HL <= din16;
                  XY_SELECT_IX: IX <= din16;
                  XY_SELECT_IY: IY <= din16;
                endcase
              7: SP <= din16;          
              8: IX <= din16;
              9: IY <= din16;
            endcase
          end
      if (flags_we)
        AF[7:0] <= flags_in;
    end  
end

always @(*)
begin
  case (dout8sel)
    0: dout8 = BC[15:8];
    1: dout8 = BC[7:0];
    2: dout8 = DE[15:8];
    3: dout8 = DE[7:0];
    4: 
      case (xy_sel)
        XY_SELECT_HL: dout8 = HL[15:8];
        XY_SELECT_IX: dout8 = IX[15:8];
        XY_SELECT_IY: dout8 = IY[15:8];
      endcase
    5: 
      case (xy_sel)
        XY_SELECT_HL: dout8 = HL[7:0];    
        XY_SELECT_IX: dout8 = IX[7:0];
        XY_SELECT_IY: dout8 = IY[7:0];
      endcase
    7: dout8 = AF[15:8];
    8: dout8 = BC[15:8];
    9: dout8 = BC[7:0];
    10: dout8 = DE[15:8];
    11: dout8 = DE[7:0];
    12: dout8 = HL[15:8];
    13: dout8 = HL[7:0];    
    15: dout8 = AF[15:8];
    16: dout8 = IR[15:8];    
    17: dout8 = IR[7:0];   
    default: dout8 = 8'bX;
  endcase
end

always @(*)
begin
  case (dout16sel)
    0: dout16 = BC;
    1: dout16 = DE;
    2: 
      case (xy_sel)
        XY_SELECT_HL: dout16 = HL;   
        XY_SELECT_IX: dout16 = IX;
        XY_SELECT_IY: dout16 = IY;
      endcase
    3: dout16 = AF;
    4: dout16 = BC;
    5: dout16 = DE;
    6: 
      case (xy_sel)
        XY_SELECT_HL: dout16 = HL;   
        XY_SELECT_IX: dout16 = IX;
        XY_SELECT_IY: dout16 = IY;
      endcase
    7: dout16 = SP;
    8: dout16 = IX;
    9: dout16 = IY;
    default: dout16 = 16'bX;
  endcase
end

always @(posedge clk)
begin

end
  
endmodule
