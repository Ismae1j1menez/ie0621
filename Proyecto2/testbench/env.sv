class arb_env extends uvm_env;

  `uvm_component_utils(arb_env)

  function new (string name = "arb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual interface_bus_master vif;
  sdram_agent_active sdram_ag_active;
  sdram_agent_passive sdram_ag_passive;
  sdram_scoreboard sb;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
    
    sdram_ag_active = sdram_agent_active::type_id::create("sdram_ag_active", this);
    sdram_ag_passive = sdram_agent_passive::type_id::create("sdram_ag_passive", this);
    sb = sdram_scoreboard::type_id::create("sb", this);
    
    // Nota revision: Esta comando no se si va aqui, pues estaba comentado en el FIFO
  //  uvm_config_db #(virtual interface_bus_master)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", vif);
    
    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
    print();
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sdram_ag_passive.sdram_mntr_r.mon_analysis_port.connect(sb.sb_mon);
    sdram_ag_active.sdram_mntr_w.mon_analysis_port.connect(sb.sb_drv);
  endfunction

endclass
