wire uc_ip_to_addr;
assign uc_ip_to_addr = ucode[12];
wire uc_rd;
assign uc_rd = ucode[13];
wire uc_inc_ip;
assign uc_inc_ip = ucode[14];
wire [1:0] uc_decode;
assign uc_decode = ucode[16:15];
wire [0:0] uc_read_target;
assign uc_read_target = ucode[17:17];
wire [0:0] uc_din8_target;
assign uc_din8_target = ucode[18:18];
wire [1:0] uc_din8_source;
assign uc_din8_source = ucode[20:19];
wire [0:0] uc_dout8_sel;
assign uc_dout8_sel = ucode[21:21];
