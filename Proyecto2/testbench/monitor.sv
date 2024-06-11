class monitor;
  scoreboard sb;
  virtual interface_bus_master vif_int;
  
  int err_count;
  bit [31:0] addr, data;
  bit write_en;
  logic [31:0] sb_value;
  
  function new(virtual interface_bus_master vif_ext, scoreboard sb);
    this.vif_int = vif_ext;
    this.sb = sb;
  endfunction

  task check();
    err_count = 0;
    // Siempre esta ejecutando, porque debe estar revisando constantemente
    forever begin
      @ (posedge vif_int.sys_clk);
      // Si estan en esta configuracion las señales significa que se esta escribiendo un dato
      if (vif_int.wb_stb_i == 1 && vif_int.wb_cyc_i == 1 && vif_int.wb_we_i == 1) begin 
        sb.add_entry(vif_int.wb_addr_i, vif_int.wb_addr_i, vif_int.wb_dat_i, 1'b0);
        
        // Utilizado para sincronizar y esperar al ack para saber que se puede esribir el dato
        do begin
          @ (posedge vif_int.sys_clk);
        end while(vif_int.wb_ack_o == 1'b0); // Debe esperar a recibir el ack
        if (sb.find_entry(vif_int.wb_addr_i, addr, data, write_en) == 0) begin  
          
        sb.add_entry(vif_int.wb_addr_i, vif_int.wb_addr_i, vif_int.wb_dat_i, 1'b0);
        end
        @ (negedge vif_int.sys_clk);
      end
      
      // Si estan en estea configuracion estas señales significa que se esta leyendo un dato 
      if (vif_int.wb_we_i == 0 && vif_int.wb_stb_i == 1 && vif_int.wb_cyc_i == 1) begin 
		
        // Utilizado para sincronizar y esperar al ack para saber que se puede leer el dato
        do begin
          @(posedge vif_int.sys_clk); 
        end while (vif_int.wb_ack_o == 1'b0); // Debe esperar a recibir el ack
        sb_value = sb.find_entry(vif_int.wb_addr_i, addr, data, write_en); 
        $display("Test:                               Expected SB value: %0h, DUT output: %0h", data, vif_int.wb_dat_o);
        
        // Realiza la comparacion entre el dato leido de la SDRAM con el guardado en el scoreboard
        if (vif_int.wb_dat_o != data ) begin
          $display("Test Estatus:                       * ERROR * DUT data is %0h :: SB data is %0h", vif_int.wb_dat_o, data);
          err_count++;
          
        end else begin
          if (vif_int.wb_dat_o)begin
          $display("Test Estatus:                       * PASS * DUT data is %0h :: SB data is %0h", vif_int.wb_dat_o, data);
          end else begin
            $display("Test Estatus:                       * Value not found * DUT data is %0h", vif_int.wb_dat_o);
          end
        end
      end
    end 
  endtask 
endclass
