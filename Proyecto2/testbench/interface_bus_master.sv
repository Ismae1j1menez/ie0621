// Definition of a SystemVerilog interface used to model the bus master's behavior in a verification environment.
interface interface_bus_master(input logic sys_clk, input logic sdram_clk);
  // General signals for the bus interface and clocks.
  logic RESETN;          // Active low reset signal.
  logic wb_clk_i;        // Wishbone bus clock input.
  logic wb_stb_i;        // Strobe signal, indicates a valid data transfer cycle.
  logic wb_ack_o;        // Acknowledge signal from the slave, indicates completion of data transfer.
  logic wb_we_i;         // Write enable signal, high for write operations, low for read operations.
  logic [31:0] wb_addr_i; // Address bus, specifies the memory or register address for the data transfer.
  logic [31:0] wb_dat_i;  // Data bus input, carries data from master to slave during write operations.
  logic [31:0] wb_dat_o;  // Data bus output, carries data from slave to master during read operations.
  logic [3:0] wb_sel_i;   // Byte select signals, specifies which byte lanes to operate during the transfer.
  logic wb_cyc_i;         // Cycle signal, high during a valid bus cycle.
  logic [2:0] wb_cti_i;   // Cycle type identifier, used to define the type of the current bus cycle in complex transactions.

endinterface : interface_bus_master
