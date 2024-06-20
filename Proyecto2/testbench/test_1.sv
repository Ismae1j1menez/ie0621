// La clase `test_1` hereda de `uvm_test`, sirviendo como clase base para crear pruebas UVM.
class test_1 extends uvm_test;
  // Macro de utilidad para proporcionar registro de fábrica y otras utilidades.
  `uvm_component_utils(test_1)
  
  // Constructor de la clase `test_1`.
  function new(string name = "test_1", uvm_component parent = null);
    super.new(name, parent); // Llama al constructor de la clase base
  endfunction : new

  // Declaración de una interfaz virtual de tipo `interface_bus_master`.
  virtual interface_bus_master vif;
  // Instancia del entorno `arb_env` que encapsula los componentes del entorno de verificación.
  arb_env env;
  
  // Fase de construcción para configurar el entorno de la prueba.
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Llama a la fase de construcción de la clase base
    
    // Recupera la interfaz virtual de la base de datos de configuración UVM.
    if(uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
        // Si no se encuentra la interfaz virtual, emite un error fatal para detener la simulación.
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end

    // Crea la instancia del entorno `env` usando la fábrica UVM.
    env = arb_env::type_id::create("env", this);
    // Establece la interfaz virtual en la base de datos de configuración UVM accesible para todos los componentes bajo `uvm_test_top`.
    uvm_config_db #(virtual interface_bus_master)::set(null, "uvm_test_top.*", "VIRTUAL_INTERFACE", vif);
  endfunction : build_phase

  // Fase de finalización de la elaboración para realizar cualquier acción justo antes de que comience la simulación.
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    // Informa el final de la fase de elaboración.
    uvm_report_info(get_full_name(), "End_of_elaboration", UVM_LOW);
    print(); // Llama a print para mostrar la jerarquía de componentes u otra información de depuración.
  endfunction : end_of_elaboration_phase
  
  // Declarar una secuencia `gen_item_seq` que se utilizará para generar estímulos.
  gen_item_seq seq;

  // La fase principal de ejecución de la prueba.
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this); // Levanta una objeción para evitar que la fase termine prematuramente.
    uvm_report_info(get_full_name(), "Init Start", UVM_LOW); // Registra el inicio de la inicialización.
    env.sdram_ag_active.arb_drv.reset(); // Llama a reset en el controlador dentro del agente SDRAM activo.
    uvm_report_info(get_full_name(), "Init Done", UVM_LOW);  // Registra la finalización de la inicialización.
    
    // Crea y comienza la secuencia.
    seq = gen_item_seq::type_id::create("seq");
    seq.randomize(); // Randomiza la secuencia para introducir variabilidad.
    seq.start(env.sdram_ag_active.sdram_seqr); // Inicia la secuencia en el secuenciador designado.

    // Ejecuta una función para imprimir el contenido de la memoria después de la ejecución de la secuencia para verificación.
    env.sdram_ag_active.arb_drv.print_memory_contents();
    phase.drop_objection(this); // Baja la objeción permitiendo que la fase termine.
  endtask

endclass
