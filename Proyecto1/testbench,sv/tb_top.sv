/********************************************************************
*  Top-Level Testbench (tb_top)
*  This module serves as the top-level testbench. It initializes 
*  the system clocks, instantiates the SDRAM controller, and 
*  connects the test program to the bus interface for simulation.
********************************************************************/
`include "interface_bus_master.sv"
`include "scoreboard.sv"
`include "stimulus.sv"
`include "monitor.sv"
`include "driver_bus_master.sv"
`include "env.sv"
//`include "test1.sv"
//`include "test2.sv"
`include "test3.sv"
`timescale 1ns/1ps

module tb_top;

  //------------------------------------------------
  // Instance Declarations
  // This section declares instances of the scoreboard and the 
  // bus interface, as well as the driver for the bus master.
  //------------------------------------------------
  scoreboard sb;
  logic sys_clk, sdram_clk;         // Clock signals
  interface_bus_master bus(sys_clk, sdram_clk);  // Instantiate the bus interface
  driver_bus_master drv2 = new(bus, sb);         // Instantiate the bus master driver

  //------------------------------------------------
  // Clock Parameters and Initializations
  // This section defines and initializes the system and SDRAM 
  // clock signals with specific periods.
  //------------------------------------------------
  parameter P_SYS = 10;  // 200MHz clock period
  parameter P_SDR = 20;  // 100MHz clock period

  initial sys_clk = 0;
  initial sdram_clk = 0;

  always #(P_SYS/2) sys_clk = !sys_clk;  // Toggle sys_clk
  always #(P_SDR/2) sdram_clk = !sdram_clk;  // Toggle sdram_clk

  //------------------------------------------------
  // General Signals
  // This section defines general signals such as the reset signal 
  // and SDRAM clock.
  //------------------------------------------------
  reg RESETN;
  reg negreset;
  assign negreset = !RESETN;
  reg sdram_clk;

  //------------------------------------------------
  // Wishbone Interface Signals
  // This section defines the signals for the Wishbone bus interface.
  //------------------------------------------------
  parameter dw = 32;  // Data width
  parameter tw = 8;   // Tag ID width
  parameter bl = 5;   // Burst length width 

  reg wb_stb_i;
  wire wb_ack_o;
  reg [25:0] wb_addr_i;
  reg wb_we_i;            // Write enable (1: Write, 0: Read)
  reg [dw-1:0] wb_dat_i;
  reg [dw/8-1:0] wb_sel_i;  // Byte enable
  wire [dw-1:0] wb_dat_o;
  reg wb_cyc_i;
  reg [2:0] wb_cti_i;

  //------------------------------------------------
  // SDRAM Interface Signals
  // This section defines the signals for interfacing with the SDRAM.
  //------------------------------------------------
  `ifdef SDR_32BIT
    wire [31:0] Dq;         // SDRAM Read/Write Data Bus
    wire [3:0] sdr_dqm;     // SDRAM Data Mask
  `elsif SDR_16BIT 
    wire [15:0] Dq;         // SDRAM Read/Write Data Bus
    wire [1:0] sdr_dqm;     // SDRAM Data Mask
  `else 
    wire [7:0] Dq;          // SDRAM Read/Write Data Bus
    wire [0:0] sdr_dqm;     // SDRAM Data Mask
  `endif

  wire [1:0] sdr_ba;         // SDRAM Bank Select
  wire [12:0] sdr_addr;      // SDRAM Address
  wire sdr_init_done;        // SDRAM Initialization Done

  wire #(2.0) sdram_clk_d = sdram_clk;  // Adjust SDRAM clock timing

  //------------------------------------------------
  // SDRAM Controller Instantiation
  // This section instantiates the SDRAM controller based on the 
  // configured data width (32-bit, 16-bit, or 8-bit).
  //------------------------------------------------
  `ifdef SDR_32BIT
    sdrc_top #(.SDR_DW(32),.SDR_BW(4)) u_dut(
  `elsif SDR_16BIT 
    sdrc_top #(.SDR_DW(16),.SDR_BW(2)) u_dut(
  `else  // 8 BIT SDRAM
    sdrc_top #(.SDR_DW(8),.SDR_BW(1)) u_dut(
  `endif
      // System configuration
      `ifdef SDR_32BIT
          .cfg_sdr_width(2'b00), // 32-bit SDRAM
      `elsif SDR_16BIT
          .cfg_sdr_width(2'b01), // 16-bit SDRAM
      `else 
          .cfg_sdr_width(2'b10), // 8-bit SDRAM
      `endif
          .cfg_colbits(2'b00), // 8-bit Column Address

      /* WISHBONE Interface */
      .wb_rst_i(!bus.RESETN),
      .wb_clk_i(sys_clk),
      .wb_stb_i(bus.wb_stb_i),
      .wb_ack_o(bus.wb_ack_o),
      .wb_addr_i(bus.wb_addr_i),
      .wb_we_i(bus.wb_we_i),
      .wb_dat_i(bus.wb_dat_i),
      .wb_sel_i(bus.wb_sel_i),
      .wb_dat_o(bus.wb_dat_o),
      .wb_cyc_i(bus.wb_cyc_i),
      .wb_cti_i(bus.wb_cti_i),

      /* Interface to SDRAM */
      .sdram_clk(sdram_clk),
      .sdram_resetn(bus.RESETN),
      .sdr_cs_n(sdr_cs_n),
      .sdr_cke(sdr_cke),
      .sdr_ras_n(sdr_ras_n),
      .sdr_cas_n(sdr_cas_n),
      .sdr_we_n(sdr_we_n),
      .sdr_dqm(sdr_dqm),
      .sdr_ba(sdr_ba),
      .sdr_addr(sdr_addr), 
      .sdr_dq(Dq),

      /* Parameters */
      .sdr_init_done(sdr_init_done),
      .cfg_req_depth(2'h3),      // Request buffer depth
      .cfg_sdr_en(1'b1),
      .cfg_sdr_mode_reg(13'h033),
      .cfg_sdr_tras_d(4'h4),
      .cfg_sdr_trp_d(4'h2),
      .cfg_sdr_trcd_d(4'h2),
      .cfg_sdr_cas(3'h3),
      .cfg_sdr_trcar_d(4'h7),
      .cfg_sdr_twr_d(4'h1),
      .cfg_sdr_rfsh(12'h100),    // Refresh rate
      .cfg_sdr_rfmax(3'h6)
  );

  //------------------------------------------------
  // SDRAM Instantiation
  // This section instantiates the SDRAM model based on the 
  // configured data width (32-bit, 16-bit, or 8-bit).
  //------------------------------------------------
  `ifdef SDR_32BIT
    mt48lc2m32b2 #(.data_bits(32)) u_sdram32 (
      .Dq(Dq), 
      .Addr(sdr_addr[10:0]), 
      .Ba(sdr_ba), 
      .Clk(sdram_clk_d), 
      .Cke(sdr_cke), 
      .Cs_n(sdr_cs_n), 
      .Ras_n(sdr_ras_n), 
      .Cas_n(sdr_cas_n), 
      .We_n(sdr_we_n), 
      .Dqm(sdr_dqm)
    );
  `elsif SDR_16BIT
    IS42VM16400K u_sdram16 (
      .dq(Dq), 
      .addr(sdr_addr[11:0]), 
      .ba(sdr_ba), 
      .clk(sdram_clk_d), 
      .cke(sdr_cke), 
      .csb(sdr_cs_n), 
      .rasb(sdr_ras_n), 
      .casb(sdr_cas_n), 
      .web(sdr_we_n), 
      .dqm(sdr_dqm)
    );
  `else 
    mt48lc8m8a2 #(.data_bits(8)) u_sdram8 (
      .Dq(Dq), 
      .Addr(sdr_addr[11:0]), 
      .Ba(sdr_ba), 
      .Clk(sdram_clk_d), 
      .Cke(sdr_cke), 
      .Cs_n(sdr_cs_n), 
      .Ras_n(sdr_ras_n), 
      .Cas_n(sdr_cas_n), 
      .We_n(sdr_we_n), 
      .Dqm(sdr_dqm)
    );
  `endif 

  //------------------------------------------------
  // Testcase Instantiation
  // This section connects the test program to the bus interface, 
  // running the specified test scenario.
  //------------------------------------------------
  testcase test(bus);

endmodule
