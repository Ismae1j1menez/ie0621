class arb_item extends uvm_sequence_item;
  `uvm_object_utils_begin(arb_item)
  `uvm_field_int(writte, UVM_ALL_ON)
  `uvm_field_int(bl, UVM_ALL_ON)
  `uvm_field_int(amount_times, UVM_ALL_ON)
  `uvm_field_int(Address, UVM_ALL_ON)
  `uvm_field_int(command, UVM_ALL_ON)
  `uvm_field_int(delay, UVM_ALL_ON)
  `uvm_field_int(iterations, UVM_ALL_ON)
  `uvm_field_int(iteration_write, UVM_ALL_ON)
  `uvm_field_int(iteration_read, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "arb_item");
    super.new(name);
  endfunction

  randc bit [31:0] writte;
  rand bit [7:0] bl;
  randc bit [7:0] amount_times;
  rand bit [31:0] Address;
  rand bit [1:0] command;
  rand bit [7:0] delay;
  rand bit [3:0] iterations;
  rand bit [2:0] iteration_write;
  rand bit [2:0] iteration_read;

  constraint bl_c { bl >= 8 && bl <= 15; }
  constraint amount_times_c { amount_times inside {[1:255]}; }
  constraint command_c { command inside {0, 1}; }
  constraint delay_c { delay inside {[1:255]}; }
  constraint iterations_c { iterations inside {1, 2, 3, 4}; }
endclass

class gen_item_seq extends uvm_sequence #(arb_item);
  `uvm_object_utils(gen_item_seq)

  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  rand int num;
  constraint c1 { num inside {[2:5]}; }

  virtual task body();
    for (int i = 0; i < num; i++) begin
      arb_item f_item = arb_item::type_id::create("f_item");

      start_item(f_item);
      f_item.randomize() with {command == 0;};
      `uvm_info("SEQ", $sformatf("Generate new item command 0: "), UVM_LOW)
      f_item.print();
      finish_item(f_item);

      start_item(f_item);
      f_item.randomize() with {command == 1;};
      `uvm_info("SEQ", $sformatf("Generate new item command 0: "), UVM_LOW)
      f_item.print();
      finish_item(f_item);

    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass

class arb_driver extends uvm_driver #(arb_item);
  `uvm_component_utils(arb_driver)

  uvm_analysis_port #(arb_item) analysis_port;

  function new (string name = "arb_driver", uvm_component parent = null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  virtual interface_bus_master vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif)) begin
      `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      arb_item f_item;
      `uvm_info("DRV", $sformatf("Esperando ítem del secuenciador"), UVM_LOW)
      seq_item_port.get_next_item(f_item);
      
      if (f_item.command == 0) begin
        burst_write(f_item);
      end else if (f_item.command == 1) begin
        burst_read(f_item.Address); // Corrected line
      end

      analysis_port.write(f_item);

      seq_item_port.item_done();
    end
  endtask

  virtual task reset();
    vif.wb_addr_i      = 0;
    vif.wb_dat_i       = 0;
    vif.wb_sel_i       = 4'h0;
    vif.wb_we_i        = 1;
    vif.wb_stb_i       = 0;
    vif.wb_cyc_i       = 0;
    vif.RESETN         = 1'h1;
    #100

    vif.RESETN         = 1'h0;
    #10000;

    vif.RESETN         = 1'h1;
    #1000;
    wait(top_hdl.u_dut.sdr_init_done == 1);
    #1000;
    `uvm_info("DRV", "Se aplicó el RESET", UVM_LOW)
  endtask

  virtual task burst_write(arb_item f_item);
    int i;
    $display("Inicio de la tarea burst_write");
    @ (negedge vif.sys_clk);
    for (i = 0; i < f_item.bl; i++) begin
      vif.wb_stb_i = 1;
      vif.wb_cyc_i = 1;
      vif.wb_we_i = 1;
      vif.wb_sel_i = 4'b1111;
      vif.wb_addr_i = {f_item.Address[31:2] + i, 2'b00};
      $display("Activadas las señales del bus.");

      vif.wb_dat_i = f_item.writte;
		f_item.writte += 100;
      do begin
        @(posedge vif.sys_clk);
      end while (vif.wb_ack_o == 1'b0);
      @(negedge vif.sys_clk);
      $display("Número de ráfaga: %d, Dirección de escritura: %h, Dato escrito: %h", i, vif.wb_addr_i, vif.wb_dat_i);
    end
    vif.wb_stb_i = 0;
    vif.wb_cyc_i = 0;
    vif.wb_we_i = 'hx;
    vif.wb_sel_i = 'hx;
    vif.wb_addr_i = 'hx;
    vif.wb_dat_i = 'hx;
    $display("Finalizado el proceso de escritura.");
  endtask

   virtual task burst_read(bit[31:0] address);
    int j;
    $display("Inicio de la tarea burst_read.");

    for (j = 0; j < 16; j++) begin 
      vif.wb_stb_i = 1;
      vif.wb_cyc_i = 1;
      vif.wb_we_i = 0;
      vif.wb_addr_i = address + (j * 4);
      $display("Activadas las señales del bus.");

      do begin
        @ (posedge vif.sys_clk);
      end while (vif.wb_ack_o == 1'b0);
      $display("Número de ráfaga: %d, ACK recibido para dirección %h, Dato recibido: %h", j, vif.wb_addr_i, vif.wb_dat_o);
      @(negedge vif.sdram_clk);
    end
    vif.wb_stb_i = 0;
    vif.wb_cyc_i = 0;
    vif.wb_we_i = 'hx;
    vif.wb_addr_i = 'hx;
    $display("Finalizado el proceso de lectura.");
  endtask
endclass
