// Clase base para monitores SDRAM que extiende de uvm_monitor
class sdram_monitor extends uvm_monitor;
  // Utilidad para el registro de componentes UVM
  `uvm_component_utils(sdram_monitor)

  // Interfaz del bus maestro virtual
  virtual interface_bus_master vif;

  // Bandera para habilitar la verificación
  bit enable_check = 0;

  // Bandera para habilitar la cobertura
  bit enable_coverage = 0;

  // Puerto de análisis para enviar objetos de análisis a los componentes de análisis
  uvm_analysis_port #(arb_item) mon_analysis_port;

  // Constructor de la clase
  function new (string name, uvm_component parent=null);
    super.new(name, parent); // Llama al constructor de la clase base
  endfunction

  // Fase de construcción para configurar componentes UVM
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase); // Llama a la fase de construcción de la clase base
    mon_analysis_port = new("mon_analysis_port", this); // Instancia el puerto de análisis

    // Configuración de la interfaz virtual a través de la base de datos de configuración de UVM
    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
       // Si no se puede obtener la interfaz virtual, emite un error fatal
       `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
  endfunction

  // Fase de ejecución: esta fase está vacía en la clase base
  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase); // Llama a la fase de ejecución de la clase base
  endtask   
endclass


// Clase para monitorear operaciones de escritura en SDRAM, extiende de sdram_monitor
class sdram_monitor_w extends sdram_monitor;
  // Utilidad para el registro de componentes UVM
  `uvm_component_utils(sdram_monitor_w)
  
  // Constructor de la clase
  function new(string name, uvm_component parent=null);
    super.new(name, parent); // Llama al constructor de la clase base
  endfunction

  // Fase de construcción: no se modifica en esta subclase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Llama a la fase de construcción de la clase base
  endfunction
  
  // Fase de ejecución: monitorear señales de escritura y capturar datos relevantes
  virtual task run_phase (uvm_phase phase);
    arb_item data_obj = arb_item::type_id::create("data_obj", this); // Crea un nuevo objeto de tipo arb_item
  
    forever begin
      @(posedge vif.sys_clk); // Espera al flanco positivo del reloj del sistema
      // Condiciones para detectar una operación de escritura válida
      if (vif.wb_stb_i == 1 && vif.wb_cyc_i == 1 && vif.wb_we_i == 1 && vif.wb_ack_o == 1'b1) begin
        data_obj = arb_item::type_id::create("data_obj", this); // Crea un nuevo objeto de tipo arb_item
        data_obj.Address = vif.wb_addr_i; // Asigna la dirección de la operación de escritura
        data_obj.writte = vif.wb_dat_i; // Asigna los datos de la operación de escritura
        data_obj.command = 1;  // Indicador de comando de escritura
        mon_analysis_port.write(data_obj); // Envía el objeto de datos al puerto de análisis
      end
    end
  endtask
endclass

// Clase para monitorear operaciones de lectura en SDRAM, extiende de sdram_monitor
class sdram_monitor_r extends sdram_monitor;
  // Utilidad para el registro de componentes UVM
  `uvm_component_utils(sdram_monitor_r) 

  // Constructor de la clase
  function new (string name, uvm_component parent=null);
    super.new(name, parent); // Llama al constructor de la clase base
  endfunction

  // Fase de construcción: no se modifica en esta subclase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase); // Llama a la fase de construcción de la clase base
  endfunction

  // Fase de ejecución: monitorear señales de lectura y capturar datos relevantes
  virtual task run_phase (uvm_phase phase);
    arb_item data_obj = arb_item::type_id::create("data_obj", this); // Crea un nuevo objeto de tipo arb_item
    forever begin
      @(posedge vif.sys_clk); // Espera al flanco positivo del reloj del sistema
      // Condiciones para detectar una operación de lectura válida
      if (vif.wb_stb_i == 1 && vif.wb_cyc_i == 1 && vif.wb_we_i == 0 && vif.wb_ack_o == 1'b1) begin
        data_obj = arb_item::type_id::create("data_obj", this); // Crea un nuevo objeto de tipo arb_item
        data_obj.Address = vif.wb_addr_i; // Asigna la dirección de la operación de lectura
        data_obj.writte = vif.wb_dat_o; // Asigna los datos de la operación de lectura
        data_obj.command = 0;  // Indicador de comando de lectura
        mon_analysis_port.write(data_obj); // Envía el objeto de datos al puerto de análisis
      end
    end
  endtask
endclass
