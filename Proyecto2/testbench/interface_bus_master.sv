interface interface_bus_master(input sys_clk, sdram_clk);
  logic RESETN, wb_clk_i, wb_stb_i, wb_ack_o, wb_we_i;
  logic [31:0] wb_addr_i, wb_dat_i, wb_dat_o;
  logic [3:0] wb_sel_i;
  logic wb_cyc_i;
  logic [2:0] wb_cti_i;
endinterface : interface_bus_master