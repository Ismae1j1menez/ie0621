class scoreboard;
  // Estructura para almacenar los valores
  typedef struct {
    bit [31:0] address;
    bit [31:0] data;
    bit        write_enable;
  } data_t;

  // Diccionario usando un array
  data_t dict[bit[31:0]];

  // Método para añadir una nueva entrada
  function void add_entry(bit[31:0] id, bit[31:0] address, bit[31:0] data, bit write_enable);
    data_t new_data;
    new_data.address = address;
    new_data.data = data;
    new_data.write_enable = write_enable;
    // Actualiza el dato si ya existe, añade datos si no existe
    dict[id] = new_data;
    $display("Adding Entry - ID %h:          Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable);
  endfunction

  // Método para buscar una entrada por ID y devolver sus valores
  function bit find_entry(bit[31:0] id, output bit[31:0] address, output bit[31:0] data, output bit write_enable);
    
    if (dict.exists(id)) begin
      address = dict[id].address;
      data = dict[id].data;
      write_enable = dict[id].write_enable;
      $display("Entry found - ID %h:          Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable);
      return 1; 
    end else begin
      $display("No entry found for ID %h:", id);
      return 0;
    end
  endfunction

  // Método para iterar sobre el diccionario, para mostrar todos los valores ingresados
  function void iterate();
    foreach(dict[id]) begin
      $display("ID: %d, Address: %h, Data: %h, Write Enable: %b", id, dict[id].address, dict[id].data, dict[id].write_enable);
    end
  endfunction

endclass