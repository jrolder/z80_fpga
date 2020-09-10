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
    input wire [2:0] din16sel,
    input wire [2:0] dout16sel,
    input wire [7:0] flags_in,
    output wire [7:0] flags_out,
    input wire din8we,
    input wire din16we,
    input wire flags_we,
    output wire [7:0] aout8
    );

reg [15:0] BC;
reg [15:0] DE;
reg [15:0] HL;
reg [15:0] AF;

reg [15:0] SP;
reg [15:0] IX;
reg [15:0] IY;
    
assign aout8 = AF[15:8];
assign flags_out = AF[7:0];
    
// 8sel is B, C, D, E, H, L, -, A, IXH, IXL, IYH, IYL
// 16sel is BC, DE, HL, AF, SP, IX, IY

always @(posedge clk)
begin
  if (din8we)
  begin
    case (din8sel)
      0: BC[15:8] <= din8;
      1: BC[7:0] <= din8;
      2: DE[15:8] <= din8;
      3: DE[7:0] <= din8;
      4: HL[15:8] <= din8;
      5: HL[7:0] <= din8;
      7: AF[15:8] <= din8;
      8: IX[15:8] <= din8;
      9: IX[7:0] <= din8;
      10: IY[15:8] <= din8;
      11: IY[7:0] <= din8;
    endcase
  end
end

always @(*)
begin
  case (dout8sel)
    0: dout8 = BC[15:8];
    1: dout8 = BC[7:0];
    2: dout8 = DE[15:8];
    3: dout8 = DE[7:0];
    4: dout8 = HL[15:8];
    5: dout8 = HL[7:0];    
    7: dout8 = AF[15:8];
    8: dout8 = IX[15:8];    
    9: dout8 = IX[7:0];
    10: dout8 = IY[15:8];    
    11: dout8 = IY[7:0];   
    default: dout8 = 8'bX;
  endcase
end

// BC, DE, HL, AF, SP, IX, IY
always @(posedge clk)
begin
  if (din16we)
  begin
    case (din16sel)
      0: BC <= din16;
      1: DE <= din16;
      2: HL <= din16;
      3: AF <= din16;
      4: SP <= din16;
      5: IX <= din16;
      6: IY <= din16;
    endcase
  end
end

always @(*)
begin
  case (dout16sel)
    0: dout16 = BC;
    1: dout16 = DE;
    2: dout16 = HL;
    3: dout16 = AF;
    4: dout16 = SP;
    5: dout16 = IX;
    6: dout16 = IY;
    default: dout16 = 16'bX;
  endcase
end

always @(posedge clk)
begin
  if (flags_we)
    AF[7:0] <= flags_in;
end
  
endmodule
