/********************************************************************
*  Top-Level Module `top_hdl`
*  This module serves as the top-level hardware description layer (HDL) 
*  for the SDRAM interface and related Wishbone bus connections. It 
*  generates clock signals, connects the design under test (DUT), and 
*  sets up the virtual interface for the UVM environment.
********************************************************************/
import uvm_pkg::*; // Import UVM package
`include "uvm_macros.svh" // Include UVM macros
`timescale 1ns/1ps // Set timescale

module top_hdl();
  logic sys_clk, sdram_clk; // System and SDRAM clock signals

  //------------------------------------------------
  // Clock Parameters
  // Define the clock periods for the system clock (200MHz) 
  // and the SDRAM clock (100MHz).
  //------------------------------------------------
  parameter P_SYS  = 10; // 200MHz
  parameter P_SDR  = 20; // 100MHz

  //------------------------------------------------
  // Clock Generation
  // Initial block to generate system and SDRAM clocks.
  //------------------------------------------------
  initial sys_clk = 0;
  initial sdram_clk = 0;
  always #(P_SYS/2) sys_clk = ~sys_clk; // Toggle sys_clk
  always #(P_SDR/2) sdram_clk = ~sdram_clk; // Toggle sdram_clk

  //------------------------------------------------
  // Interface Declaration
  // Instantiate the interface for the bus master.
  //------------------------------------------------
  interface_bus_master vif(sys_clk, sdram_clk);

  //------------------------------------------------
  // DUT Connection
  // Connect the DUT (SDRAM controller) to the Wishbone interface 
  // and the SDRAM signals.
  //------------------------------------------------
  
  parameter dw = 32;  // Data width
  parameter tw = 8;   // Tag ID width
  parameter bl = 5;   // Burst length width 

  //-------------------------------------------
  // WISHBONE Interface Signals
  // Define the signals required for the Wishbone bus interface.
  //-------------------------------------------
  reg             wb_stb_i;
  wire            wb_ack_o;
  reg  [25:0]     wb_addr_i;
  reg             wb_we_i; // 1 - Write, 0 - Read
  reg  [dw-1:0]   wb_dat_i;
  reg  [dw/8-1:0] wb_sel_i; // Byte enable
  wire  [dw-1:0]  wb_dat_o;
  reg             wb_cyc_i;
  reg   [2:0]     wb_cti_i;

  //--------------------------------------------
  // SDRAM Interface Signals
  // Define the signals required to interface with the SDRAM.
  //--------------------------------------------
  `ifdef SDR_32BIT
    wire [31:0] Dq; // SDRAM Read/Write Data VIF
    wire [3:0]  sdr_dqm; // SDRAM Data Mask
  `elsif SDR_16BIT 
    wire [15:0] Dq; // SDRAM Read/Write Data VIF
    wire [1:0]  sdr_dqm; // SDRAM Data Mask
  `else 
    wire [7:0]  Dq; // SDRAM Read/Write Data VIF
    wire [0:0]  sdr_dqm; // SDRAM Data Mask
  `endif

  wire [1:0]  sdr_ba; // SDRAM Bank Select
  wire [12:0] sdr_addr; // SDRAM Address
  wire        sdr_init_done; // SDRAM Initialization Done signal

  // Fix the SDRAM interface timing issue by delaying the clock signal
  wire #(2.0) sdram_clk_d = sdram_clk;

  //------------------------------------------------
  // SDRAM Controller Instantiation
  // Instantiate the SDRAM controller (DUT) based on the configured data width.
  //------------------------------------------------
  `ifdef SDR_32BIT
    sdrc_top #(.SDR_DW(32), .SDR_BW(4)) u_dut(
  `elsif SDR_16BIT 
    sdrc_top #(.SDR_DW(16), .SDR_BW(2)) u_dut(
  `else  // 8 BIT SDRAM
    sdrc_top #(.SDR_DW(8), .SDR_BW(1)) u_dut(
  `endif
    // System Configuration
    `ifdef SDR_32BIT
      .cfg_sdr_width (2'b00), // 32-bit SDRAM
    `elsif SDR_16BIT
      .cfg_sdr_width (2'b01), // 16-bit SDRAM
    `else 
      .cfg_sdr_width (2'b10), // 8-bit SDRAM
    `endif
    .cfg_colbits (2'b00), // 8-bit Column Address

    /* WISHBONE Interface */
    .wb_rst_i (!vif.RESETN),
    .wb_clk_i (sys_clk),
    .wb_stb_i (vif.wb_stb_i),
    .wb_ack_o (vif.wb_ack_o),
    .wb_addr_i (vif.wb_addr_i),
    .wb_we_i (vif.wb_we_i),
    .wb_dat_i (vif.wb_dat_i),
    .wb_sel_i (vif.wb_sel_i),
    .wb_dat_o (vif.wb_dat_o),
    .wb_cyc_i (vif.wb_cyc_i),
    .wb_cti_i (vif.wb_cti_i),

    /* SDRAM Interface */
    .sdram_clk (sdram_clk),
    .sdram_resetn (vif.RESETN),
    .sdr_cs_n (sdr_cs_n),
    .sdr_cke (sdr_cke),
    .sdr_ras_n (sdr_ras_n),
    .sdr_cas_n (sdr_cas_n),
    .sdr_we_n (sdr_we_n),
    .sdr_dqm (sdr_dqm),
    .sdr_ba (sdr_ba),
    .sdr_addr (sdr_addr), 
    .sdr_dq (Dq),

    /* Parameters */
    .sdr_init_done (sdr_init_done),
    .cfg_req_depth (2'h3), // Request buffer depth
    .cfg_sdr_en (1'b1),
    .cfg_sdr_mode_reg (13'h033),
    .cfg_sdr_tras_d (4'h4),
    .cfg_sdr_trp_d (4'h2),
    .cfg_sdr_trcd_d (4'h2),
    .cfg_sdr_cas (3'h3),
    .cfg_sdr_trcar_d (4'h7),
    .cfg_sdr_twr_d (4'h1),
    .cfg_sdr_rfsh (12'h100), // Reduced from 12'hC35
    .cfg_sdr_rfmax (3'h6)
  );

  //------------------------------------------------
  // SDRAM Model Instantiation
  // Instantiate the appropriate SDRAM model based on the configured data width.
  //------------------------------------------------
  `ifdef SDR_32BIT
    mt48lc2m32b2 #(.data_bits(32)) u_sdram32 (
      .Dq (Dq), 
      .Addr (sdr_addr[10:0]), 
      .Ba (sdr_ba), 
      .Clk (sdram_clk_d), 
      .Cke (sdr_cke), 
      .Cs_n (sdr_cs_n), 
      .Ras_n (sdr_ras_n), 
      .Cas_n (sdr_cas_n), 
      .We_n (sdr_we_n), 
      .Dqm (sdr_dqm)
    );
  `elsif SDR_16BIT
    IS42VM16400K u_sdram16 (
      .dq (Dq), 
      .addr (sdr_addr[11:0]), 
      .ba (sdr_ba), 
      .clk (sdram_clk_d), 
      .cke (sdr_cke), 
      .csb (sdr_cs_n), 
      .rasb (sdr_ras_n), 
      .casb (sdr_cas_n), 
      .web (sdr_we_n), 
      .dqm (sdr_dqm)
    );
  `else 
    mt48lc8m8a2 #(.data_bits(8)) u_sdram8 (
      .Dq (Dq), 
      .Addr (sdr_addr[11:0]), 
      .Ba (sdr_ba), 
      .Clk (sdram_clk_d), 
      .Cke (sdr_cke), 
      .Cs_n (sdr_cs_n), 
      .Ras_n (sdr_ras_n), 
      .Cas_n (sdr_cas_n), 
      .We_n (sdr_we_n), 
      .Dqm (sdr_dqm)
    );
  `endif

  //------------------------------------------------
  // Initial Block
  // Set up the simulation environment by dumping waveforms and 
  // setting the virtual interface.
  //------------------------------------------------
  initial begin
    $dumpfile("dump.vcd"); // Specify the VCD file for waveform output
    $dumpvars; // Dump all variables for waveform viewing

    // Set the virtual interface in the UVM configuration database
    uvm_config_db #(virtual interface_bus_master)::set (null, "uvm_test_top", "VIRTUAL_INTERFACE", vif);
  end

endmodule
