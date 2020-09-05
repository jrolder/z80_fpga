      0: ucode <= UC_IP_TO_ADDR | UC_RD | UC_INC_IP | UC_RD_IR | UC_DECODE1 | 1;
      1: ucode <= 0;
      2: ucode <= 0;
      3: ucode <= UC_IP_TO_ADDR | UC_RD | UC_INC_IP | UC_DIN8_SRC_RAM | UC_DIN8_DST_IR543 | 0;
      4: ucode <= UC_DIN8_SRC_DOUT8 | UC_DIN8_DST_IR543 | UC_DOUT8_SEL_IR210 | 0;
