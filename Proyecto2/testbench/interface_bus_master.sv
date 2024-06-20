interface interface_bus_master(input logic sys_clk, input logic sdram_clk);
  logic RESETN;
  logic wb_clk_i;
  logic wb_stb_i;
  logic wb_ack_o;
  logic wb_we_i;
  logic [31:0] wb_addr_i;
  logic [31:0] wb_dat_i;
  logic [31:0] wb_dat_o;
  logic [3:0] wb_sel_i;
  logic wb_cyc_i;
  logic [2:0] wb_cti_i;
endinterface : interface_bus_master
