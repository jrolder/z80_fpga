wire uc_ip_to_addr;
assign uc_ip_to_addr = ucode[12];
wire uc_rd;
assign uc_rd = ucode[13];
wire [1:0] uc_command;
assign uc_command = ucode[15:14];
wire [2:0] uc_ucode_goto;
assign uc_ucode_goto = ucode[18:16];
wire [1:0] uc_read_target;
assign uc_read_target = ucode[20:19];
wire [0:0] uc_din8_target;
assign uc_din8_target = ucode[21:21];
wire [1:0] uc_din8_source;
assign uc_din8_source = ucode[23:22];
wire [0:0] uc_dout8_sel;
assign uc_dout8_sel = ucode[24:24];
wire [1:0] uc_din16_source;
assign uc_din16_source = ucode[26:25];
wire [0:0] uc_din16_sel;
assign uc_din16_sel = ucode[27:27];
wire [0:0] uc_flags_source;
assign uc_flags_source = ucode[28:28];
wire [1:0] uc_alu8_source;
assign uc_alu8_source = ucode[30:29];
wire [0:0] uc_alu8_op;
assign uc_alu8_op = ucode[31:31];
wire [1:0] uc_ip_op;
assign uc_ip_op = ucode[33:32];
