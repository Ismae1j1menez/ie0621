// Importa el paquete UVM y las macros necesarias
import uvm_pkg::*;
`include "uvm_macros.svh"
// Define la precisión temporal del testbench
`timescale 1ns/1ps

// Módulo top-level para la simulación del testbench
module top_hdl();
  // Señales de reloj para el sistema y la SDRAM
  logic sys_clk, sdram_clk;

  // Períodos de los relojes del sistema y de la SDRAM
  parameter P_SYS = 10;     
  parameter P_SDR = 20;     

  // Inicialización de los relojes
  initial sys_clk = 0;
  initial sdram_clk = 0;
  // Generación de los relojes del sistema y de la SDRAM
  always #(P_SYS/2) sys_clk = ~sys_clk;
  always #(P_SDR/2) sdram_clk = ~sdram_clk;

  // Instanciación de la interfaz del bus maestro
  interface_bus_master vif(sys_clk, sdram_clk);

  // Parámetros configurables de la interfaz
  parameter dw = 32;       // Ancho de datos
  parameter tw = 8;        // Ancho de la transacción
  parameter bl = 5;        // Longitud del burst

  // Señales del bus Wishbone
  reg wb_stb_i;
  wire wb_ack_o;
  reg [25:0] wb_addr_i;
  reg wb_we_i;
  reg [dw-1:0] wb_dat_i;
  reg [dw/8-1:0] wb_sel_i;
  wire [dw-1:0] wb_dat_o;
  reg wb_cyc_i;
  reg [2:0] wb_cti_i;

  // Condicional para la configuración del ancho de datos de la SDRAM
  `ifdef SDR_32BIT
    wire [31:0] Dq;
    wire [3:0] sdr_dqm;
  `elsif SDR_16BIT 
    wire [15:0] Dq;
    wire [1:0] sdr_dqm;
  `else 
    wire [7:0] Dq;
    wire [0:0] sdr_dqm;
  `endif

  // Señales adicionales de la SDRAM
  wire [1:0] sdr_ba;
  wire [12:0] sdr_addr;
  wire sdr_init_done;

  // Retardo adicional en la señal de reloj de la SDRAM
  wire #(2.0) sdram_clk_d = sdram_clk;

  // Instanciación condicional del módulo principal del controlador SDRAM
  `ifdef SDR_32BIT
    sdrc_top #(.SDR_DW(32), .SDR_BW(4)) u_dut(
  `elsif SDR_16BIT 
    sdrc_top #(.SDR_DW(16), .SDR_BW(2)) u_dut(
  `else
    sdrc_top #(.SDR_DW(8), .SDR_BW(1)) u_dut(
  `endif
    // Configuración del módulo principal del controlador SDRAM
    .cfg_sdr_width (2'b00),  // Ancho de configuración
    .cfg_colbits (2'b00),    // Bits de columna

    // Conexión de las señales de control y datos
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

    // Conexión de las señales adicionales de la SDRAM
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

    // Señales de configuración y estado del módulo de la SDRAM
    .sdr_init_done (sdr_init_done),
    .cfg_req_depth (2'h3),
    .cfg_sdr_en (1'b1),
    .cfg_sdr_mode_reg (13'h033),
    .cfg_sdr_tras_d (4'h4),
    .cfg_sdr_trp_d (4'h2),
    .cfg_sdr_trcd_d (4'h2),
    .cfg_sdr_cas (3'h3),
    .cfg_sdr_trcar_d (4'h7),
    .cfg_sdr_twr_d (4'h1),
    .cfg_sdr_rfsh (12'h100),
    .cfg_sdr_rfmax (3'h6)
  );

  // Instanciación condicional de los módulos de memoria SDRAM
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

  // Configuración inicial para la simulación, incluyendo la configuración de la interfaz UVM
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    uvm_config_db #(virtual interface_bus_master)::set (null, "uvm_test_top", "VIRTUAL_INTERFACE", vif);
  end

endmodule