/****************Agregar Test2********************/

/*Este test utiliza valores randomizados de row, bank y column para escribir en la memoria*/
program testcase(interface_bus_master vif_int);
  environment env = new(vif_int);
  stimulusB stiB;
  stimulus sti;
  
  reg [7:0] rafagas;
  reg [31:0] address;
  reg [11:0] row;
  reg [1:0] bank;
  reg [7:0] column; 
  
  initial begin
    $display("############################################################");
    $display("Comenzando el test2");
    stiB = new();
    sti=new();
    assert(stiB.randomize()) else $fatal(0,"Randomization failed");
    assert(sti.randomize()) else $fatal(0,"Randomization failed");
    row = stiB.row;
    bank = stiB.bank;
    column = stiB.column;
    rafagas = sti.bl; 
    address = {row, bank, column, 2'b00};
    env.drvr.reset();
    env.drvr.burst_write(address,rafagas);
    #1000;
    env.drvr.burst_read(address,rafagas);
    #10000;
    $finish;
    $display("############################################################");
  end
endprogram
