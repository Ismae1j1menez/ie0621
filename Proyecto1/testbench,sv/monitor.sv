/********************************************************************
*  Monitor Class
*  The monitor continuously checks the signals on the bus to track 
*  write and read operations. It compares the observed values with 
*  those stored in the scoreboard to validate the data integrity.
********************************************************************/
class monitor;

  //------------------------------------------------
  // Members and Variables
  // This section defines the scoreboard instance, the virtual 
  // interface, and variables to store address, data, and errors.
  //------------------------------------------------
  scoreboard sb;
  virtual interface_bus_master vif_int;
  
  int err_count;              // Error counter
  bit [31:0] addr, data;      // Variables to hold address and data
  bit write_en;               // Write enable flag
  logic [31:0] sb_value;      // Value retrieved from the scoreboard
  
  //------------------------------------------------
  // Constructor
  // Initializes the monitor with the virtual interface and scoreboard.
  //------------------------------------------------
  function new(virtual interface_bus_master vif_ext, scoreboard sb);
    this.vif_int = vif_ext;
    this.sb = sb;
  endfunction

  //------------------------------------------------
  // Task: check
  // This task continuously monitors the bus signals, adding 
  // entries to the scoreboard during write operations and 
  // validating read data against the scoreboard.
  //------------------------------------------------
  task check();
    err_count = 0;

    // Continuous monitoring loop
    forever begin
      @ (posedge vif_int.sys_clk);

      // Check if a write operation is happening
      if (vif_int.wb_stb_i == 1 && vif_int.wb_cyc_i == 1 && vif_int.wb_we_i == 1) begin 
        sb.add_entry(vif_int.wb_addr_i, vif_int.wb_addr_i, vif_int.wb_dat_i, 1'b0);
        
        // Wait for acknowledgment signal (ack) before proceeding
        do begin
          @ (posedge vif_int.sys_clk);
        end while (vif_int.wb_ack_o == 1'b0);

        if (sb.find_entry(vif_int.wb_addr_i, addr, data, write_en) == 0) begin  
          sb.add_entry(vif_int.wb_addr_i, vif_int.wb_addr_i, vif_int.wb_dat_i, 1'b0);
        end
        @ (negedge vif_int.sys_clk);
      end
      
      // Check if a read operation is happening
      if (vif_int.wb_we_i == 0 && vif_int.wb_stb_i == 1 && vif_int.wb_cyc_i == 1) begin 
        
        // Wait for acknowledgment signal (ack) before proceeding
        do begin
          @(posedge vif_int.sys_clk); 
        end while (vif_int.wb_ack_o == 1'b0);

        sb_value = sb.find_entry(vif_int.wb_addr_i, addr, data, write_en); 
        $display("Test: Expected SB value: %0h, DUT output: %0h", data, vif_int.wb_dat_o);
        
        // Compare the read data with the scoreboard data
        if (vif_int.wb_dat_o != data) begin
          $display("Test Status: * ERROR * DUT data is %0h :: SB data is %0h", vif_int.wb_dat_o, data);
          err_count++;
          
        end else begin
          if (vif_int.wb_dat_o != null) begin
            $display("Test Status: * PASS * DUT data is %0h :: SB data is %0h", vif_int.wb_dat_o, data);
          end else begin
            $display("Test Status: * Value not found * DUT data is %0h", vif_int.wb_dat_o);
          end
        end
      end
    end 
  endtask 
endclass
