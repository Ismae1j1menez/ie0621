/********************************************************************
*  Class `sdram_agent_active`
*  This class represents the active agent for the SDRAM in the UVM 
*  verification environment. It is responsible for generating stimuli 
*  through the sequencer and handling write operations via the driver.
********************************************************************/
class sdram_agent_active extends uvm_agent;

  //------------------------------------------------
  // UVM Class Registration
  // Macro to register the `sdram_agent_active` class with UVM.
  //------------------------------------------------
  `uvm_component_utils(sdram_agent_active)

  //------------------------------------------------
  // Constructor
  // Initializes the active agent with an optional name and parent component.
  //------------------------------------------------
  function new(string name = "sdram_agent_active", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  //------------------------------------------------
  // Component and Interface Declarations
  // Defines the components necessary for the active agent, 
  // including the driver, sequencer, and write monitor.
  //------------------------------------------------
  virtual interface_bus_master vif;
  sdram_driver sdram_drv; 
  uvm_sequencer #(sdram_item) sdram_seqr; 
  sdram_monitor_w sdram_mntr_w; 
  sdram_scoreboard sb; 

  //------------------------------------------------
  // Build Phase
  // Instantiates and configures the agent's components, 
  // including retrieving the virtual interface.
  //------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Retrieve the virtual interface from the UVM configuration database
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not retrieve the virtual interface for the TB")
    end
    
    // Create instances of the agent's components
    sdram_drv = sdram_driver::type_id::create("sdram_drv", this);
    sdram_seqr = uvm_sequencer#(sdram_item)::type_id::create("sdram_seqr", this);
    sdram_mntr_w = sdram_monitor_w::type_id::create("sdram_mntr_w", this);
    sb = sdram_scoreboard::type_id::create("sb", this);
    
    // Configure the virtual interface for the driver
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.sdram_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  //------------------------------------------------
  // Connect Phase
  // Links the necessary ports and exports between the 
  // agent's components.
  //------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    sdram_drv.seq_item_port.connect(sdram_seqr.seq_item_export);
    sdram_drv.vif = vif;
    sdram_mntr_w.vif = vif;
  endfunction

endclass


/********************************************************************
*  Class `sdram_agent_passive`
*  This class represents the passive agent for the SDRAM in the UVM 
*  verification environment. It is responsible for monitoring the 
*  SDRAM read operations.
********************************************************************/
class sdram_agent_passive extends uvm_agent;

  //------------------------------------------------
  // UVM Class Registration
  // Macro to register the `sdram_agent_passive` class with UVM.
  //------------------------------------------------
  `uvm_component_utils(sdram_agent_passive)

  //------------------------------------------------
  // Constructor
  // Initializes the passive agent with a name and parent component.
  //------------------------------------------------
  function new(string name="sdram_agent_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  //------------------------------------------------
  // Interface and Component Declarations
  // Defines the virtual interface and read monitor required 
  // for the passive agent.
  //------------------------------------------------
  virtual interface_bus_master vif;
  sdram_monitor_r sdram_mntr_r;  

  //------------------------------------------------
  // Build Phase
  // Instantiates and configures the passive agent's components, 
  // including retrieving the virtual interface.
  //------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Retrieve the virtual interface from the UVM configuration database
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not retrieve the virtual interface for the TB")
    end
    
    // Create instance of the read monitor
    sdram_mntr_r = sdram_monitor_r::type_id::create("sdram_mntr_r", this);
    
    // Configure the virtual interface for the read monitor
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.sdram_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  //------------------------------------------------
  // Connect Phase
  // In the passive agent, the connect phase is empty since 
  // no additional port connections are required.
  //------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass
