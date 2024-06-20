// Declaraciones de puertos de análisis para instancias de 'driver' y 'monitor'
`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class sdram_scoreboard extends uvm_component;
  // Macro para registrar la clase `sdram_scoreboard` en UVM
  `uvm_component_utils(sdram_scoreboard)
  
  // Constructor de la clase `sdram_scoreboard`
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Declaraciones de puertos de análisis para recibir ítems desde el driver y el monitor
  uvm_analysis_imp_drv #(arb_item, sdram_scoreboard) sb_drv;
  uvm_analysis_imp_mon #(arb_item, sdram_scoreboard) sb_mon;
  
  // Fase de construcción del componente
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_drv = new("sb_drv", this); // Instanciación del puerto de análisis para el driver
    sb_mon = new("sb_mon", this); // Instanciación del puerto de análisis para el monitor
  endfunction

  // Estructura para almacenar datos de las operaciones de memoria
  typedef struct {
    bit [31:0] address;       // Dirección de la memoria afectada
    bit [31:0] data;          // Datos involucrados en la operación
    bit        write_enable;  // Indicador si la operación es de escritura
  } data_t;

  // Diccionario para almacenar los datos, indexado por dirección
  data_t dict[bit[31:0]];
  
  // Función para agregar una entrada al diccionario
  function void add_entry(bit[31:0] id, bit[31:0] address, bit [31:0] data, bit write_enable);
    data_t new_data;
    new_data.address = address;
    new_data.data = data;
    new_data.write_enable = write_enable;
    dict[id] = new_data; // Almacenamiento de la nueva entrada
    `uvm_info("SCOREBOARD", $sformatf("Adding Entry - ID %h: Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable), UVM_LOW)
  endfunction

  // Función para buscar una entrada específica en el diccionario
  function bit find_entry(bit[31:0] id, output bit[31:0] address, output bit[31:0] data, output bit write_enable);
    if (dict.exists(id)) begin // Chequeo de existencia de la entrada
      address = dict[id].address;
      data = dict[id].data;
      write_enable = dict[id].write_enable;
      return 1; // Indica que la entrada fue encontrada
    end else begin
      return 0; // Indica que la entrada no fue encontrada
    end
  endfunction
  
  // Función para iterar y mostrar todas las entradas del diccionario
  function void iterate();
    foreach(dict[id]) begin // Iteración sobre cada entrada en el diccionario
      `uvm_info("SCOREBOARD", $sformatf("ID: %h, Address: %h, Data: %h, Write Enable: %b", id, dict[id].address, dict[id].data, dict[id].write_enable), UVM_LOW)
    end
  endfunction

  // Función para agregar entradas al diccionario desde el driver
  function void write_drv(arb_item t);
    add_entry(t.Address, t.Address, t.writte, t.command); // Llamada a 'add_entry' con los datos del ítem
    iterate(); // Iteración para mostrar el estado actual del diccionario
  endfunction
	
  // Función para verificar las entradas desde el monitor
  function void write_mon(arb_item t);
    bit [31:0] addr;
    bit [31:0] dat;
    bit        we;
    if (find_entry(t.Address, addr, dat, we)) begin // Búsqueda de la entrada
      if (addr == t.Address && dat == t.writte) begin // Verificación de coincidencia de datos
        `uvm_info("SCOREBOARD", $sformatf("Entry matches - Passed - Address: %h, Data: %h", addr, dat), UVM_LOW)
      end
    end
  endfunction

endclass
