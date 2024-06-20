// The class `test_1` extends from `uvm_test`, serving as a base class for creating UVM tests.
class test_1 extends uvm_test;
  // Utility macro to provide factory registration and other utilities.
  `uvm_component_utils(test_1)
  
  // Constructor for the `test_1` class.
  function new(string name = "test_1", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Declaration of a virtual interface of type `interface_bus_master`.
  virtual interface_bus_master vif;
  // Instance of the environment `arb_env` which encapsulates the verification environment components.
  arb_env env;
  
  // Build phase to configure the test environment.
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Retrieve the virtual interface from the UVM configuration database.
    if(uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
        // If the virtual interface is not found, issue a fatal error to stop the simulation.
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end

    // Create the environment instance `env` using the UVM factory.
    env = arb_env::type_id::create("env", this);
    // Set the virtual interface in the UVM configuration database accessible to all components under `uvm_test_top`.
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", vif);
  endfunction : build_phase

  // End of elaboration phase to perform any actions right before simulation starts.
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    // Report the end of the elaboration phase.
    uvm_report_info(get_full_name(), "End_of_elaboration", UVM_LOW);
    print(); // Call print to display component hierarchy or other debug information.
  endfunction : end_of_elaboration_phase
  
  // Declare a sequence `gen_item_seq` which will be used to generate stimulus.
  gen_item_seq seq;

  // The main execution phase of the test.
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this); // Raise an objection to prevent the phase from finishing prematurely.
    uvm_report_info(get_full_name(), "Init Start", UVM_LOW); // Log initialization start.
    env.sdram_ag_active.arb_drv.reset(); // Call reset on the driver within the active SDRAM agent.
    uvm_report_info(get_full_name(), "Init Done", UVM_LOW);  // Log initialization completion.
    
    // Create and start the sequence.
    seq = gen_item_seq::type_id::create("seq");
    seq.randomize(); // Randomize the sequence to introduce variability.
    seq.start(env.sdram_ag_active.sdram_seqr); // Start the sequence on the designated sequencer.

    // Execute a function to print memory contents post-sequence execution for verification.
    env.sdram_ag_active.arb_drv.print_memory_contents();
    phase.drop_objection(this); // Drop the objection allowing the phase to end.
  endtask

endclass
