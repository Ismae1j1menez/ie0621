/****************Agregar Test1********************/
program testcase(interface_bus_master vif_int);
  environment env = new(vif_int);
  stimulus sti;
  reg [7:0] rafagas;
  reg [31:0] address;
  
  initial begin
    $display("############################################################");
    $display("Comenzando el test1");
    sti=new(); 
    assert(sti.randomize()) else $fatal(0,"Randomization failed");
    address =  sti.Address; 
    rafagas = sti.bl; 
    env.drvr.reset();
    env.drvr.burst_write(address,rafagas);
    #1000;
    env.drvr.burst_read(address,rafagas);
    #10000;
    
    $finish;
    $display("############################################################");
  end
endprogram
