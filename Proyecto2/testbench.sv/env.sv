/********************************************************************
*  `sdram_env` Class
*  This class defines the verification environment (`env`) in UVM, 
*  which includes the active and passive agents, as well as the 
*  scoreboard for verifying SDRAM transactions.
********************************************************************/
class sdram_env extends uvm_env;

  //------------------------------------------------
  // UVM Class Registration
  // Macro to register the `sdram_env` class with the UVM factory.
  //------------------------------------------------
  `uvm_component_utils(sdram_env)

  //------------------------------------------------
  // `sdram_env` Class Constructor
  // Initializes the environment with a name and parent component.
  //------------------------------------------------
  function new (string name = "sdram_env", uvm_component parent = null);
    super.new(name, parent); 
  endfunction
  
  //------------------------------------------------
  // Declaration of Virtual Interface and Environment Components
  // Defines the virtual interface and the instances of the agents 
  // and the scoreboard.
  //------------------------------------------------
  virtual interface_bus_master vif;
  sdram_agent_active sdram_ag_active;   
  sdram_agent_passive sdram_ag_passive; 
  sdram_scoreboard sb;                 

  //------------------------------------------------
  // Build Phase
  // Constructs the environment components, including the creation 
  // of instances of the agents and the scoreboard. It also retrieves 
  // the virtual interface from the configuration database.
  //------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); 

    // Retrieve the virtual interface from the configuration database
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Failed to obtain virtual interface for the testbench")
    end
    
    // Create instances of the agents and the scoreboard
    sdram_ag_active = sdram_agent_active::type_id::create("sdram_ag_active", this);
    sdram_ag_passive = sdram_agent_passive::type_id::create("sdram_ag_passive", this);
    sb = sdram_scoreboard::type_id::create("sb", this);
    
    // Information at the end of the build phase
    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
    print(); 
  endfunction

  //------------------------------------------------
  // Connect Phase
  // Connects the analysis ports of the monitors to the scoreboard, 
  // establishing the data flow for verification.
  //------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase); 

    // Connect the monitor's analysis ports to the scoreboard
    sdram_ag_passive.sdram_mntr_r.mon_analysis_port.connect(sb.sb_mon);
    sdram_ag_active.sdram_mntr_w.mon_analysis_port.connect(sb.sb_drv);
  endfunction

endclass
