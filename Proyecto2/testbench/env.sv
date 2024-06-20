// Define la clase `arb_env` que extiende de `uvm_env` para encapsular y gestionar todos los componentes UVM.
class arb_env extends uvm_env;

  // Macro para automatizar y simplificar la creación de fábricas y métodos de impresión.
  `uvm_component_utils(arb_env)

  // Constructor de la clase.
  function new (string name = "arb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // Declaración de las variables para la interfaz virtual y los agentes.
  virtual interface_bus_master vif;
  sdram_agent_active sdram_ag_active;
  sdram_agent_passive sdram_ag_passive;
  sdram_scoreboard sb;

  // Fase de construcción donde se configuran e inicializan los componentes.
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Obtiene la interfaz virtual configurada desde el banco de configuraciones UVM.
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end

    // Creación de instancias de agentes activos y pasivos y del scoreboard.
    sdram_ag_active = sdram_agent_active::type_id::create("sdram_ag_active", this);
    sdram_ag_passive = sdram_agent_passive::type_id::create("sdram_ag_passive", this);
    sb = sdram_scoreboard::type_id::create("sb", this);
    
    // Mensaje de confirmación de finalización de la fase de construcción.
    uvm_report_info(get_full_name(), "End_of_build_phase", UVM_LOW);
    print();
  endfunction

  // Fase de conexión donde se establecen las conexiones entre los puertos de los agentes y el scoreboard.
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Conexión de los puertos de análisis del monitor de lectura del agente pasivo al scoreboard.
    sdram_ag_passive.sdram_mntr_r.mon_analysis_port.connect(sb.sb_mon);
    // Conexión de los puertos de análisis del monitor de escritura del agente activo al scoreboard.
    sdram_ag_active.sdram_mntr_w.mon_analysis_port.connect(sb.sb_drv);
  endfunction

endclass
