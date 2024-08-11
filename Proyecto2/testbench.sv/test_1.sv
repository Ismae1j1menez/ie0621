/********************************************************************
*  Class `test_1`
*  This class inherits from `uvm_test` and serves as a base class 
*  for creating UVM tests. It sets up the test environment, configures 
*  the components, and defines the main execution sequence for the test.
********************************************************************/
class test_1 extends uvm_test;

  //------------------------------------------------
  // UVM Component Utilities
  // This macro provides factory registration and other utilities 
  // needed for the UVM framework.
  //------------------------------------------------
  `uvm_component_utils(test_1)
  
  //------------------------------------------------
  // Constructor
  // Initializes the `test_1` class with a name and a parent component.
  //------------------------------------------------
  function new(string name = "test_1", uvm_component parent = null);
    super.new(name, parent); // Calls the base class constructor
  endfunction : new

  //------------------------------------------------
  // Declarations
  // Declaration of the virtual interface and environment instance 
  // that will be used in the test.
  //------------------------------------------------
  virtual interface_bus_master vif;
  sdram_env env;               

  //------------------------------------------------
  // Build Phase
  // This phase configures the test environment, including retrieving 
  // the virtual interface from the configuration database and creating 
  // the environment instance.
  //------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Retrieves the virtual interface from the UVM configuration database
    if(uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end

    // Creates the `env` environment instance using the UVM factory
    env = sdram_env::type_id::create("env", this);

    // Sets the virtual interface in the UVM configuration database
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", vif);
  endfunction : build_phase

  //------------------------------------------------
  // End of Elaboration Phase
  // This phase performs actions just before the simulation starts, 
  // such as reporting the end of the elaboration phase and printing 
  // component information.
  //------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(), "End_of_elaboration", UVM_LOW); 
    print();
  endfunction : end_of_elaboration_phase
  
  //------------------------------------------------
  // Sequence Declaration
  // Declares a `gen_item_seq` sequence that will be used to generate stimuli.
  //------------------------------------------------
  gen_item_seq seq;

  //------------------------------------------------
  // Run Phase
  // The main execution phase of the test. It includes resetting the DUT, 
  // starting the sequence, and printing memory contents for verification.
  //------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this); 
    uvm_report_info(get_full_name(), "Init Start", UVM_LOW);

    env.sdram_ag_active.sdram_drv.reset();

    uvm_report_info(get_full_name(), "Init Done", UVM_LOW);  
    
    // Create and start the sequence
    seq = gen_item_seq::type_id::create("seq");
    seq.randomize(); 
    seq.start(env.sdram_ag_active.sdram_seqr);

    // Print the memory contents after sequence execution
    env.sdram_ag_active.sdram_drv.print_memory_contents();
    phase.drop_objection(this); 
  endtask

endclass
