// Clase para el agente activo de SDRAM, extiende de uvm_agent.
class sdram_agent_active extends uvm_agent;
  // Macro para el registro de componentes UVM
  `uvm_component_utils(sdram_agent_active)

  // Constructor del agente activo
  function new(string name = "sdram_agent_active", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // Declaración de componentes e interfaces
  virtual interface_bus_master vif;
  arb_driver arb_drv;  // Driver para manejar la arbitración
  uvm_sequencer #(arb_item) sdram_seqr;  // Secuenciador para el agente
  sdram_monitor_w sdram_mntr_w;  // Monitor de escritura
  sdram_scoreboard sb;  // Marcador para verificar la correctitud de las operaciones

  // Fase de construcción para instanciar y configurar componentes
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Obtener la interfaz virtual desde la base de datos de configuración de UVM
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
    
    // Crear instancias de los componentes del agente
    arb_drv = arb_driver::type_id::create("arb_drv", this);
    sdram_seqr = uvm_sequencer#(arb_item)::type_id::create("sdram_seqr", this);
    sdram_mntr_w = sdram_monitor_w::type_id::create("sdram_mntr_w", this);
    sb = sdram_scoreboard::type_id::create("sb", this);
    
    // Configurar la interfaz virtual para el driver
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.arb_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  // Fase de conexión para enlazar puertos y exportaciones
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Conectar el puerto de items de secuencia del driver al export del secuenciador
    arb_drv.seq_item_port.connect(sdram_seqr.seq_item_export);
    // Asignar la interfaz virtual a los componentes necesarios
    arb_drv.vif = vif;
    sdram_mntr_w.vif = vif;
  endfunction

endclass

// Clase para el agente pasivo de SDRAM, extiende de uvm_agent.
class sdram_agent_passive extends uvm_agent;
  // Macro para el registro de componentes UVM
  `uvm_component_utils(sdram_agent_passive)

  // Constructor del agente pasivo
  function new(string name="sdram_agent_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  // Declaración de interfaz virtual
  virtual interface_bus_master vif;
  sdram_monitor_r sdram_mntr_r;  // Monitor de lectura

  // Fase de construcción para instanciar y configurar componentes
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Obtener la interfaz virtual desde la base de datos de configuración de UVM
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
    
    // Crear instancia del monitor de lectura
    sdram_mntr_r = sdram_monitor_r::type_id::create("sdram_mntr_r", this);
    
    // Configurar la interfaz virtual para el monitor de lectura
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.env.sdram_ag_active.arb_drv", "VIRTUAL_INTERFACE", vif);
  endfunction

  // Fase de conexión: en esta clase, la fase de conexión está vacía
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass