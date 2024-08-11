/********************************************************************
*  SDRAM Controller Driver
*  This class implements the driver for the SDRAM controller. It 
*  handles interactions with the SDRAM, including performing reset, 
*  burst write, and burst read operations.
********************************************************************/
class driver_bus_master;

  //------------------------------------------------
  // Declaration of registers and variables
  //------------------------------------------------
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
  
  //------------------------------------------------
  // Virtual interface and constructor
  // This section includes the configuration of the 
  // interface and initializes the scoreboard.
  //------------------------------------------------
  virtual interface_bus_master vif_int;
  function new(virtual interface_bus_master vif_ext, scoreboard sb);
  		this.vif_int = vif_ext;
    	this.sb = sb;
  endfunction
  
  //------------------------------------------------
  // Task: reset
  // This task applies a reset to the system and 
  // waits for initialization to complete.
  //------------------------------------------------
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

      vif_int.RESETN         = 1'h0;
      #10000;

      vif_int.RESETN         = 1'h1;
      #1000;
      wait(tb_top.u_dut.sdr_init_done == 1);
      #1000;
      $display("############################################################");
      $display("Se aplico el RESET");
      $display("############################################################");
  endtask

  //------------------------------------------------
  // Task: burst_write
  // This task performs a burst write operation, sending 
  // multiple data words to the SDRAM in a single burst.
  //------------------------------------------------
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

  //------------------------------------------------
  // Task: burst_read
  // This task performs a burst read operation, retrieving 
  // multiple data words from the SDRAM in a single burst.
  //------------------------------------------------
  task burst_read;
    input [31:0] Address;
    input [7:0] bl;
    int j;

    begin
      $display("############################################################");
      $display("Inicio de la tarea burst_read.");
      
      @(negedge vif_int.sys_clk);

      for (j = 0; j < bl; j++) begin
        vif_int.wb_stb_i = 1;
        vif_int.wb_cyc_i = 1;
        vif_int.wb_we_i = 0;
        vif_int.wb_addr_i = {Address[31:2] + j, 2'b00};
        $display("Activadas las señales del bus.");

        do begin
          @(posedge vif_int.sys_clk);
        end while (vif_int.wb_ack_o == 1'b0);
        $display("Estado: Número de ráfaga: %d, ACK recibido para dirección %h, Dato recibido: %h", j, vif_int.wb_addr_i, vif_int.wb_dat_o);
        $display("############################################################");
        @(negedge vif_int.sdram_clk);
      end

      vif_int.wb_stb_i = 0;
      vif_int.wb_cyc_i = 0;
      vif_int.wb_we_i = 'hx;
      vif_int.wb_addr_i = 'hx;
    end
    $display("############################################################");
    $display("Finalizado el proceso de lectura y desactivadas las señales del bus.");
    $display("############################################################");
  endtask
endclass
