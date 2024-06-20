class test_1 extends uvm_test;
  `uvm_component_utils(test_1)
  
  function new(string name = "test_1", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual interface_bus_master vif;
  arb_env env;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end

    env = arb_env::type_id::create("env", this);
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", vif);
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(), "End_of_elaboration", UVM_LOW);
    print();
  endfunction : end_of_elaboration_phase
  
  gen_item_seq seq;

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    uvm_report_info(get_full_name(), "Init Start", UVM_LOW);
    env.sdram_ag_active.arb_drv.reset();
    uvm_report_info(get_full_name(), "Init Done", UVM_LOW);
    seq = gen_item_seq::type_id::create("seq");
    seq.randomize();
    seq.start(env.sdram_ag_active.sdram_seqr);
    phase.drop_objection(this);
  endtask

endclass
