// Clase del monitor esta bien no hacer cambios porfavor
class sdram_monitor extends uvm_monitor;
  `uvm_component_utils(sdram_monitor)

  virtual interface_bus_master vif;
  bit enable_check = 0;
  bit enable_coverage = 0;
  uvm_analysis_port #(arb_item) mon_analysis_port;

  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    mon_analysis_port = new("mon_analysis_port", this);

    if (uvm_config_db #(virtual interface_bus_master)::get(this, "", "VIRTUAL_INTERFACE", vif) == 0) begin
       `uvm_fatal("INTERFACE_CONNECT", "No se pudo obtener la interfaz virtual para el TB")
    end
  endfunction

  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
  endtask   
endclass


class sdram_monitor_w extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_w)
  
  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  virtual task run_phase (uvm_phase phase);
    arb_item data_obj = arb_item::type_id::create("data_obj", this);
  
    // Este forever fue modificado
    forever begin
      @(posedge vif.sys_clk);
      if (vif.wb_stb_i == 1 && vif.wb_cyc_i == 1 && vif.wb_we_i == 1 && vif.wb_ack_o == 1'b1) begin
      	data_obj = arb_item::type_id::create("data_obj", this);
        data_obj.Address = vif.wb_addr_i;
        data_obj.writte = vif.wb_dat_i;
        data_obj.command = 1;
        mon_analysis_port.write(data_obj);
      end
      
       // do begin
        //  @(posedge vif.sys_clk);
       // end while (vif.wb_ack_o == 1'b0);
       // @(negedge vif.sys_clk);
end
    
  endtask
endclass


// Esta tarea esta modificada
// Nota revision: el scoreboard no debe estar istanciado aqui, quitarlo. 
// Esta clase debe ser lo mas parecida el read del FIFO
class sdram_monitor_r extends sdram_monitor;
  `uvm_component_utils(sdram_monitor_r)
  sdram_scoreboard  sb; 
  function new(string name, uvm_component parent=null, sdram_scoreboard sb=null);
    super.new(name, parent);
    this.sb = sb;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
  bit [31:0] addr;
  arb_item data_obj;

  forever begin
    @ (posedge vif.sys_clk);

    // Ensure sb is not null before accessing
    if (sb != null && sb.get_unread_entry()) begin
      data_obj = arb_item::type_id::create("data_obj", this);
      data_obj.Address = addr;
      data_obj.command = 0; 
      mon_analysis_port.write(data_obj);
    end
  end
endtask
endclass
