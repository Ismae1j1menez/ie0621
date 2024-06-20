// Clase `arb_item` que extiende de `uvm_sequence_item` para representar un elemento transaccional en una secuencia UVM.
class arb_item extends uvm_sequence_item;
  // Utiliza macros UVM para automatizar la creación de métodos y para registrar campos que facilitan la depuración y automatización.
  `uvm_object_utils_begin(arb_item)
  `uvm_field_int(writte, UVM_ALL_ON)      // Campo para almacenar datos de escritura, visible para todas las operaciones de UVM.
  `uvm_field_int(bl, UVM_ALL_ON)          // Longitud de la ráfaga para las operaciones de bus.
  `uvm_field_int(amount_times, UVM_ALL_ON) // Cantidad de veces que se repite una operación particular.
  `uvm_field_int(Address, UVM_ALL_ON)     // Dirección de memoria para operaciones de lectura/escritura.
  `uvm_field_int(command, UVM_ALL_ON)     // Comando a ejecutar, puede ser lectura o escritura.
  `uvm_field_int(delay, UVM_ALL_ON)       // Retardo entre operaciones.
  `uvm_field_int(iterations, UVM_ALL_ON)  // Número de iteraciones para una secuencia.
  `uvm_field_int(iteration_write, UVM_ALL_ON) // Especifica el número de escrituras en una iteración.
  `uvm_field_int(iteration_read, UVM_ALL_ON)  // Especifica el número de lecturas en una iteración.
  `uvm_object_utils_end

  // Constructor de la clase, inicializa el nombre del elemento de secuencia.
  function new(string name = "arb_item");
    super.new(name);
  endfunction

  // Variables aleatorias y su tipo (randc para ciclos únicos, rand para aleatorio sin restricción).
  randc bit [31:0] writte;
  rand bit [7:0] bl;
  randc bit [7:0] amount_times;
  rand bit [31:0] Address;
  rand bit [1:0] command;
  rand bit [7:0] delay;
  rand bit [3:0] iterations;
  rand bit [2:0] iteration_write;
  rand bit [2:0] iteration_read;

  // Restricciones para asegurar valores válidos en simulación.
  constraint bl_c { bl >= 8 && bl <= 15; } // La longitud de la ráfaga debe estar entre 8 y 15.
  constraint amount_times_c { amount_times inside {[1:255]}; } // La cantidad de veces debe estar en el rango de 1 a 255.
  constraint command_c { command inside {0, 1}; } // Comando debe ser 0 o 1, donde 0 podría significar escritura y 1 lectura.
  constraint delay_c { delay inside {[1:255]}; } // El retardo debe estar entre 1 y 255 ciclos.
  constraint iterations_c { iterations inside {1, 2, 3, 4}; } // Las iteraciones deben ser 1, 2, 3 o 4.
  constraint address_c { Address inside {[32'h00000000 : 32'h00000FFC]}; } // La dirección debe estar dentro de un rango específico.
  
endclass


// Clase `gen_item_seq` que extiende de `uvm_sequence` para generar elementos `arb_item`.
class gen_item_seq extends uvm_sequence #(arb_item);
  // Utiliza la macro de UVM para facilitar la creación y registro en el sistema de fábrica de UVM.
  `uvm_object_utils(gen_item_seq)

  // Constructor de la clase que inicializa una instancia de la secuencia con un nombre opcional.
  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  // Variable aleatoria que determina el número de elementos `arb_item` a generar.
  rand int num;
  // Restricción para asegurar que el número de elementos generados esté entre 2 y 5.
  constraint c1 { num inside {[2:5]}; }

  // Cuerpo de la secuencia que realiza la generación de los elementos.
  virtual task body();
    // Bucle para generar `num` elementos.
    for (int i = 0; i < num; i++) begin
      // Crea un nuevo elemento `arb_item` usando la fábrica de UVM.
      arb_item f_item = arb_item::type_id::create("f_item");

      // Inicia el proceso de transacción para el elemento.
      start_item(f_item);
      // Randomiza los campos del elemento de acuerdo a las restricciones definidas en `arb_item`.
      f_item.randomize();
      // Registra información sobre el elemento generado para propósitos de depuración.
      `uvm_info("SEQ", $sformatf("Generate new item: command = %0d, address = %h", f_item.command, f_item.Address), UVM_LOW)
      // Imprime los detalles del elemento generado.
      f_item.print();
      // Finaliza el proceso de transacción para el elemento.
      finish_item(f_item);
    end
    // Registra información una vez que todos los elementos han sido generados.
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass


class arb_driver extends uvm_driver #(arb_item);
  `uvm_component_utils(arb_driver) // Macro para registrar el componente con la fábrica de UVM

  uvm_analysis_port #(arb_item) analysis_port; // Puerto de análisis para transmitir transacciones

  // Constructor para la clase del driver
  function new (string name = "arb_driver", uvm_component parent = null);
    super.new(name, parent); // Llamada al constructor de la clase padre
    analysis_port = new("analysis_port", this); // Inicializar el puerto de análisis
  endfunction

  virtual interface_bus_master vif; // Interfaz virtual para la comunicación del bus

  // Método de la fase de construcción para recuperar parámetros de configuración
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // Llamada a la fase de construcción de la clase padre
    if (!uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif)) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB") // Error fatal si no se encuentra la interfaz
    end
  endfunction

  // Método de la fase de conexión
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase); // Llamada a la fase de conexión de la clase padre
  endfunction

  // Método de la fase de ejecución que contiene el comportamiento principal del driver
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase); // Llamada a la fase de ejecución de la clase padre
    forever begin
      arb_item f_item; // Declarar una variable para el ítem de la secuencia
      `uvm_info("DRV", $sformatf("Esperando ítem del secuenciador"), UVM_LOW) // Mensaje de información indicando que el driver está esperando un ítem
      seq_item_port.get_next_item(f_item); // Obtener el siguiente ítem del secuenciador

      // Realizar acciones basadas en el comando en el ítem
      if (f_item.command == 0) begin
        burst_write(f_item); // Llamar al método burst_write si el comando es 0
      end else if (f_item.command == 1) begin
        burst_read(f_item.Address); // Llamar al método burst_read si el comando es 1
      end

      analysis_port.write(f_item); // Escribir el ítem en el puerto de análisis

      seq_item_port.item_done(); // Indicar que el ítem ha sido procesado
    end
  endtask

  // Tarea de reset para inicializar y resetear señales del bus y la SDRAM.
  virtual task reset();
    vif.wb_addr_i      = 0; // Resetear el bus de direcciones.
    vif.wb_dat_i       = 0; // Resetear el bus de datos.
    vif.wb_sel_i       = 4'h0; // Resetear los bits del selector.
    vif.wb_we_i        = 1; // Habilitar escritura en alto.
    vif.wb_stb_i       = 0; // Señal de strobe en bajo.
    vif.wb_cyc_i       = 0; // Señal de ciclo en bajo.
    vif.RESETN         = 1'h1; // Afirmar el reset.
    #100

    vif.RESETN         = 1'h0; // Desafirmar el reset.
    #10000;

    vif.RESETN         = 1'h1; // Reafirmar el reset.
    #1000;
    wait(top_hdl.u_dut.sdr_init_done == 1); // Esperar a que la SDRAM se inicialice.
    #1000;
    `uvm_info("DRV", "Se aplicó el RESET", UVM_LOW) // Registrar la aplicación del reset.
  endtask

  // Tarea para la operación de escritura burst.
  virtual task burst_write(arb_item f_item);
    int i;
    $display("Inicio de la tarea burst_write"); // Registrar el inicio de la tarea burst_write.
    @ (negedge vif.sys_clk); // Sincronizar con el flanco negativo del reloj del sistema.
    for (i = 0; i < f_item.bl; i++) begin // Bucle sobre la longitud de la ráfaga.
      vif.wb_stb_i = 1; // Afirmar la señal de strobe.
      vif.wb_cyc_i = 1; // Afirmar la señal de ciclo.
      vif.wb_we_i = 1; // Habilitar escritura.
      vif.wb_sel_i = 4'b1111; // Seleccionar todos los bits de datos.
      vif.wb_addr_i = {f_item.Address[31:2] + i, 2'b00}; // Incrementar la dirección para cada ráfaga.
      $display("Activadas las señales del bus."); // Registrar la activación de las señales del bus.

      vif.wb_dat_i = f_item.writte; // Escribir datos.
      f_item.writte += 100; // Incrementar los datos para propósitos de simulación.
      do begin
        @(posedge vif.sys_clk);
      end while (vif.wb_ack_o == 1'b0); // Esperar por la confirmación.
      @(negedge vif.sys_clk);
      $display("Número de ráfaga: %d, Dirección de escritura: %h, Dato escrito: %h", i, vif.wb_addr_i, vif.wb_dat_i); // Registrar los detalles de la escritura burst.
    end
    vif.wb_stb_i = 0; // Desafirmar el strobe.
    vif.wb_cyc_i = 0; // Desafirmar el ciclo.
    vif.wb_we_i = 'hx; // Poner el habilitador de escritura en estado de alta impedancia.
    vif.wb_sel_i = 'hx; // Alta impedancia para el selector.
    vif.wb_addr_i = 'hx; // Alta impedancia para la dirección.
    vif.wb_dat_i = 'hx; // Alta impedancia para los datos.
    $display("Finalizado el proceso de escritura."); // Registrar el fin de la tarea de escritura burst.
  endtask

  // Tarea para la operación de lectura burst.
  virtual task burst_read(bit[31:0] address);
    int j;
    $display("Inicio de la tarea burst_read."); // Registrar el inicio de la tarea burst_read.

    for (j = 0; j < 16; j++) begin // Realizar 16 lecturas burst.
      vif.wb_stb_i = 1; // Afirmar el strobe.
      vif.wb_cyc_i = 1; // Afirmar el ciclo.
      vif.wb_we_i = 0; // Habilitador de escritura en bajo para la operación de lectura.
      vif.wb_addr_i = address + (j * 4); // Incrementar la dirección para cada ráfaga.
      $display("Activadas las señales del bus."); // Registrar la activación de las señales del bus.

      do begin
        @ (posedge vif.sys_clk);
      end while (vif.wb_ack_o == 1'b0); // Esperar por la confirmación.
      $display("Número de ráfaga: %d, ACK recibido para dirección %h, Dato recibido: %h", j, vif.wb_addr_i, vif.wb_dat_o); // Registrar los detalles de la lectura burst.
      @(negedge vif.sdram_clk);
    end
    vif.wb_stb_i = 0; // Desafirmar el strobe.
    vif.wb_cyc_i = 0; // Desafirmar el ciclo.
    vif.wb_we_i = 'hx; // Estado de alta impedancia para el habilitador de escritura.
    vif.wb_addr_i = 'hx; // Estado de alta impedancia para la dirección.
    $display("Finalizado el proceso de lectura."); // Registrar el fin de la tarea de lectura burst.
  endtask
  
  // Tarea para imprimir el contenido de la memoria.
  virtual task print_memory_contents();
    int address;
    int num_addresses = 1024; // Número total de direcciones a leer.
    $display("Inicio de la tarea print_memory_contents."); // Registrar el inicio de la tarea de impresión de la memoria.

    for (address = 0; address < num_addresses * 4; address += 4) begin // Leer cada dirección de memoria.
      vif.wb_stb_i = 1; // Afirmar el strobe.
      vif.wb_cyc_i = 1; // Afirmar el ciclo.
      vif.wb_we_i = 0; // Habilitador de escritura en bajo para lectura.
      vif.wb_addr_i = address; // Establecer la dirección.

      do begin
        @ (posedge vif.sys_clk);
      end while (vif.wb_ack_o == 1'b0); // Esperar por la confirmación.

      $display("Dirección: %h, Dato leído: %h", address, vif.wb_dat_o); // Registrar los detalles de la lectura de la memoria.
      @(negedge vif.sdram_clk);
    end

    vif.wb_stb_i = 0; // Desafirmar el strobe.
    vif.wb_cyc_i = 0; // Desafirmar el ciclo.
    vif.wb_we_i = 'hx; // Estado de alta impedancia.
    vif.wb_addr_i = 'hx; // Estado de alta impedancia.

    $display("Finalizado el proceso de lectura de la memoria."); // Registrar el fin de la tarea de impresión de la memoria.
  endtask
endclass