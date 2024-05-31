/****************Agregar Test3********************/
/*Este test utiliza las variables randomizadas iteration_write y iteration_read para que la cantidad de escrituras y lecturas que se hacen no sean iguales*/
program testcase(interface_bus_master vif_int);
  environment env = new(vif_int);
  stimulus sti;
  reg [7:0] rafagas;
  reg [31:0] address;
  reg [2:0] iteration_write; // Nuevo campo para iterations
  reg [2:0] iteration_read; // 
  
  initial begin
    $display("############################################################");
    $display("Comenzando el test3");
    sti=new(); 
    assert(sti.randomize()) else $fatal(0,"Randomization failed");
    address =  sti.Address; 
    rafagas = sti.bl;
    iteration_write=sti.iteration_write;
    iteration_read= sti.iteration_read;
    env.drvr.reset();
    env.drvr.burst_write(address,rafagas+iteration_write);
    #1000;
    env.drvr.burst_read(address,rafagas+iteration_read);
    #10000;
    
    $finish;
    $display("############################################################");
  end
endprogram
