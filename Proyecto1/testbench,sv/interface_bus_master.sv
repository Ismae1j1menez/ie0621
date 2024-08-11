/********************************************************************
*  Bus Master Interface
*  This interface defines the signals packaged in the interface system, 
*  including clocks, reset, and Wishbone signals.
********************************************************************/
interface interface_bus_master(input sys_clk, sdram_clk);

  //------------------------------------------------
  // Control Signals
  // These signals control the operation of the bus.
  //------------------------------------------------
  logic RESETN;         // Active-low reset signal
  logic wb_clk_i;       // Wishbone clock input

  //------------------------------------------------
  // Wishbone Signals
  // This section includes signals used in the 
  // Wishbone bus protocol for communication.
  //------------------------------------------------
  logic wb_stb_i;       // Strobe signal
  logic wb_ack_o;       // Acknowledge signal
  logic wb_we_i;        // Write enable signal
  logic [31:0] wb_addr_i;  // Address bus
  logic [31:0] wb_dat_i;   // Data input bus
  logic [31:0] wb_dat_o;   // Data output bus
  logic [3:0] wb_sel_i;    // Byte select signal
  logic wb_cyc_i;       // Cycle valid signal
  logic [2:0] wb_cti_i; // Cycle type identifier

endinterface : interface_bus_master
