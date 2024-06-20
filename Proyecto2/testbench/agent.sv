class sdram_agent_active extends uvm_agent;
  `uvm_component_utils(sdram_agent_active)

  function new(string name = "sdram_agent_active", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual interface_bus_master vif;
  arb_driver arb_drv;
  uvm_sequencer #(arb_item) sdram_seqr;
  sdram_monitor_w sdram_mntr_w;
  
  // Nota revision: el scoreboard no se si esta bien que este instanciado aqui
  sdram_scoreboard sb;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
    
    arb_drv = arb_driver::type_id::create("arb_drv", this);
    sdram_seqr = uvm_sequencer#(arb_item)::type_id::create("sdram_seqr", this);
    sdram_mntr_w = sdram_monitor_w::type_id::create("sdram_mntr_w", this);
    
    // Nota revision: el scoreboard no se si esta bien que este instanciado aqui
    sb = sdram_scoreboard::type_id::create("sb", this);
    
    // Nota revision: Esta comando no se si va aqui, pues estaba comentado en el FIFO
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.arb_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  // Nota revision: Estas conexiones estan diferentes en el FIFO
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    arb_drv.seq_item_port.connect(sdram_seqr.seq_item_export);
    arb_drv.vif = vif;
    sdram_mntr_w.vif = vif;
  endfunction

endclass

class sdram_agent_passive extends uvm_agent;
  `uvm_component_utils(sdram_agent_passive)

  function new(string name="sdram_agent_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual interface_bus_master vif;
  sdram_monitor_r sdram_mntr_r;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
    
    sdram_mntr_r = sdram_monitor_r::type_id::create("sdram_mntr_r", this);
    
    // Nota revision: Esta comando no se si va aqui, pues estaba comentado en el FIFO
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.arb_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass
