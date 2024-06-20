class arb_env extends uvm_env;

  // Macro para registrar la clase `arb_env` en UVM
  `uvm_component_utils(arb_env)

  // Constructor de la clase `arb_env`
  function new (string name = "arb_env", uvm_component parent = null);
    super.new(name, parent); // Llama al constructor de la clase base
  endfunction
  
  // Declaración de la interfaz virtual y componentes del entorno de verificación
  virtual interface_bus_master vif;
  sdram_agent_active sdram_ag_active;   // Agente SDRAM activo (generador de estímulos)
  sdram_agent_passive sdram_ag_passive; // Agente SDRAM pasivo (monitor)
  sdram_scoreboard sb;                  // Scoreboard para verificar la correcta ejecución

  // Fase de construcción del entorno
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Llama a la fase de construcción de la clase base

    // Obtener la interfaz virtual de la base de datos de configuración
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      // Si no se puede obtener la interfaz virtual, emite un error fatal
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
    
    // Crear instancias de los agentes y el scoreboard
    sdram_ag_active = sdram_agent_active::type_id::create("sdram_ag_active", this);
    sdram_ag_passive = sdram_agent_passive::type_id::create("sdram_ag_passive", this);
    sb = sdram_scoreboard::type_id::create("sb", this);
    
    // Nota de revisión: Este comando estaba comentado en el FIFO y no se está seguro si debe ser incluido aquí
    // uvm_config_db #(virtual interface_bus_master)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", vif);
    
    // Información al finalizar la fase de construcción
    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
    print(); // Imprimir detalles del componente
  endfunction

  // Fase de conexión del entorno
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase); // Llama a la fase de conexión de la clase base

    // Conectar el puerto de análisis del monitor al scoreboard
    sdram_ag_passive.sdram_mntr_r.mon_analysis_port.connect(sb.sb_mon);
    sdram_ag_active.sdram_mntr_w.mon_analysis_port.connect(sb.sb_drv);
  endfunction

endclass
