/********************************************************************
*  SDRAM Monitor Classes
*  These classes are used to monitor the SDRAM interface signals in a 
*  UVM environment, capturing read and write operations and sending 
*  the data to an analysis port for further verification.
********************************************************************/

//------------------------------------------------------------------
// Base Class `sdram_monitor`
// This base class extends `uvm_monitor` and provides the fundamental 
// structure for specific read and write monitors.
//------------------------------------------------------------------
class sdram_monitor extends uvm_monitor;

  // Utility for registering the class with UVM
  `uvm_component_utils(sdram_monitor)

  //------------------------------------------------
  // Variable Declarations
  // This section includes the virtual interface for the bus master, 
  // flags to enable checking and coverage, and an analysis port for 
  // sending captured data.
  //------------------------------------------------
  virtual interface_bus_master vif; 
  bit enable_check = 0;            
  bit enable_coverage = 0;          
  uvm_analysis_port #(sdram_item) mon_analysis_port; // Analysis port

  //------------------------------------------------
  // Class Constructor
  // Initializes the monitor with an optional name and parent component.
  //------------------------------------------------
  function new (string name, uvm_component parent=null);
    super.new(name, parent); 
  endfunction

  //------------------------------------------------
  // Build Phase
  // Configures the virtual interface and the analysis port for the 
  // monitor, retrieving the interface from the configuration database.
  //------------------------------------------------
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase); 
    mon_analysis_port = new("mon_analysis_port", this); 

    // Configure the virtual interface through the UVM configuration database
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Failed to obtain virtual interface for the testbench")
    end
  endfunction

  //------------------------------------------------
  // Run Phase
  // This phase is left empty in the base class and will be implemented 
  // in derived classes to monitor specific operations.
  //------------------------------------------------
  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
  endtask   
endclass


//------------------------------------------------------------------
// `sdram_monitor_w` Class (Write)
// Monitors write operations to the SDRAM, capturing relevant data 
// and sending it to the analysis port.
//------------------------------------------------------------------
class sdram_monitor_w extends sdram_monitor;

  // Utility for registering the class with UVM
  `uvm_component_utils(sdram_monitor_w)
  
  //------------------------------------------------
  // Class Constructor
  // Initializes the write monitor with a name and parent component.
  //------------------------------------------------
  function new(string name, uvm_component parent=null);
    super.new(name, parent); 
  endfunction

  //------------------------------------------------
  // Build Phase
  // Not modified in this subclass, inherited directly from the base class.
  //------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
  endfunction
  
  //------------------------------------------------
  // Run Phase
  // Monitors the write signals and captures relevant data, sending 
  // it to the analysis port.
  //------------------------------------------------
  virtual task run_phase (uvm_phase phase);
    sdram_item data_obj = sdram_item::type_id::create("data_obj", this); // Create a new sdram_item object
  
    forever begin
      @(posedge vif.sys_clk); 
      // Conditions to detect a valid write operation
      if (vif.wb_stb_i == 1 && vif.wb_cyc_i == 1 && vif.wb_we_i == 1 && vif.wb_ack_o == 1'b1) begin
        data_obj = sdram_item::type_id::create("data_obj", this); // Create a new sdram_item object
        data_obj.Address = vif.wb_addr_i; // Assign the address of the write operation
        data_obj.writte = vif.wb_dat_i;  // Assign the data of the write operation
        data_obj.command = 1;  // Write command indicator
        mon_analysis_port.write(data_obj); // Send the data object to the analysis port
      end
    end
  endtask
endclass


//------------------------------------------------------------------
// `sdram_monitor_r` Class (Read)
// Monitors read operations from the SDRAM, capturing relevant data 
// and sending it to the analysis port.
//------------------------------------------------------------------
class sdram_monitor_r extends sdram_monitor;

  // Utility for registering the class with UVM
  `uvm_component_utils(sdram_monitor_r) 

  //------------------------------------------------
  // Class Constructor
  // Initializes the read monitor with an optional name and parent component.
  //------------------------------------------------
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  //------------------------------------------------
  // Build Phase
  // Not modified in this subclass, inherited directly from the base class.
  //------------------------------------------------
  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
  endfunction

  //------------------------------------------------
  // Run Phase
  // Monitors the read signals and captures relevant data, sending 
  // it to the analysis port.
  //------------------------------------------------
  virtual task run_phase (uvm_phase phase);
    sdram_item data_obj = sdram_item::type_id::create("data_obj", this); // Create a new sdram_item object
    
    forever begin
      @(posedge vif.sys_clk); 
      // Conditions to detect a valid read operation
      if (vif.wb_stb_i == 1 && vif.wb_cyc_i == 1 && vif.wb_we_i == 0 && vif.wb_ack_o == 1'b1) begin
        data_obj = sdram_item::type_id::create("data_obj", this); // Create a new sdram_item object
        data_obj.Address = vif.wb_addr_i; // Assign the address of the read operation
        data_obj.writte = vif.wb_dat_o;  // Assign the data of the read operation
        data_obj.command = 0;  // Read command indicator
        mon_analysis_port.write(data_obj); // Send the data object to the analysis port
      end
    end
  endtask
endclass
