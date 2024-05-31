//------------------------------ Class driver -----------------------------------//
class driver_bus_master;
  stimulus sti;
  stimulusB stiB;
  scoreboard sb;
  reg [7:0] rafagas;
  reg [31:0] address;
  reg [11:0] row;
  reg [1:0] bank;
  reg [7:0] column; 
  reg sys_clk;
  reg sdram_clk;
  
  //Conexion de la interfaz con el driver
  virtual interface_bus_master vif_int;
  function new(virtual interface_bus_master vif_ext, scoreboard sb);
  		this.vif_int = vif_ext;
    	this.sb = sb;
  endfunction
  
  //------------------------------ Task reset -------------------------------------//
  task reset();
      sti = new();
      vif_int.wb_addr_i      = 0;
      vif_int.wb_dat_i       = 0;
      vif_int.wb_sel_i       = 4'h0;
      vif_int.wb_we_i        = 1;
      vif_int.wb_stb_i       = 0;
      vif_int.wb_cyc_i       = 0;
      vif_int.RESETN         = 1'h1;
      #100

      // Aplicando reset
      vif_int.RESETN         = 1'h0;
      #10000;

      // Soltando reset
      vif_int.RESETN         = 1'h1;
      #1000;
      // Esperar hasta que el sdr_init_donde el top sea 1
      wait(tb_top.u_dut.sdr_init_done == 1);
      #1000;
      $display("############################################################");
    $display("Se aplico el RESET");
      $display("############################################################");
  endtask

  
  //------------------------------ Task write ------------------------------------//
  task burst_write;
    input [31:0] Address;
      input [7:0] bl;
      int i;
      begin
        $display("############################################################");
        $display("Inicio de la tarea burst_write");
          sti = new();
          sb = new();
        
          @ (negedge vif_int.sys_clk);
          for (i = 0; i < bl; i++) begin
              vif_int.wb_stb_i = 1;
              vif_int.wb_cyc_i = 1;
              vif_int.wb_we_i = 1;
              vif_int.wb_sel_i = 4'b1111;
              vif_int.wb_addr_i = {Address[31:2] + i, 2'b00};
              $display("Activadas las señales del bus.");
              
              // Revisa si se genero el valor, sino imprimira mensaje de fallo
              assert(sti.randomize()) else $fatal(0,"Randomization failed");
            $display("Escritura del dato a la SDRM.");
              vif_int.wb_dat_i = sti.writte;

				
            do begin
                  @ (posedge vif_int.sys_clk);
              end while(vif_int.wb_ack_o == 1'b0);
                  @ (negedge vif_int.sys_clk);
            $display("Estado: Número de ráfaga:  %d, Dirección de escritura: %h, Dato escrito: %h", i, vif_int.wb_addr_i, vif_int.wb_dat_i); 
            $display("############################################################");
          end
          vif_int.wb_stb_i = 0;
          vif_int.wb_cyc_i = 0;
          vif_int.wb_we_i = 'hx;
          vif_int.wb_sel_i = 'hx;
          vif_int.wb_addr_i = 'hx;
          vif_int.wb_dat_i = 'hx;
          $display("############################################################");
          $display("Finalizado el proceso de escritura y desactivadas las señales del bus.");
          $display("############################################################");
      end
  endtask


  //------------------------------ Task read -------------------------------------//
  task burst_read;
    input [31:0] Address;
    input [7:0] bl;
    int j;

    begin
      $display("############################################################");
      $display("Inicio de la tarea burst_read.");
      
      @(negedge vif_int.sys_clk);
      //$display("Después del flanco negativo del reloj del sistema: Comienzo de la lectura de ráfaga");

      for (j = 0; j < bl; j++) begin
        vif_int.wb_stb_i = 1;  // Activar la señal de strobe
        vif_int.wb_cyc_i = 1;  // Activar la señal de ciclo
        vif_int.wb_we_i = 0;  // Establecer el bus en modo de lectura
        vif_int.wb_addr_i = {Address[31:2] + j, 2'b00};  // Configurar dirección de lectura
        $display("Activadas las señales del bus.");


        do begin
          @(posedge vif_int.sys_clk);  // Esperar al flanco positivo del reloj
        end while (vif_int.wb_ack_o == 1'b0);  // Esperar hasta recibir la señal de acuse de recibo
        $display("Estado: Número de ráfaga: %d, ACK recibido para dirección %h, Dato recibido: %h", j, vif_int.wb_addr_i, vif_int.wb_dat_o);
        $display("############################################################");
        @(negedge vif_int.sdram_clk);
      end

      vif_int.wb_stb_i = 0;  // Desactivar la señal de strobe
      vif_int.wb_cyc_i = 0;  // Desactivar la señal de ciclo
      vif_int.wb_we_i = 'hx;  // Limpiar la señal de escritura
      vif_int.wb_addr_i = 'hx;  // Limpiar la dirección
    end
       $display("############################################################");
       $display("Finalizado el proceso de lectura y desactivadas las señales del bus.");
       $display("############################################################");
  endtask
endclass