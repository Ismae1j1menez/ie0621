/********************************************************************
*  Test1 Program
*  This program defines a specific test scenario (Test1) for the 
*  system, utilizing the environment and stimulus classes to 
*  perform a sequence of operations, including reset, write, and read.
********************************************************************/
program testcase(interface_bus_master vif_int);

  //------------------------------------------------
  // Environment and Variables
  // This section creates instances of the environment 
  // and stimulus, and declares necessary variables.
  //------------------------------------------------
  environment env = new(vif_int);
  stimulus sti;
  reg [7:0] rafagas;
  reg [31:0] address;
  
  //------------------------------------------------
  // Initial Block
  // This block defines the sequence of operations for Test1, 
  // including randomization, reset, burst write, and burst read.
  //------------------------------------------------
  initial begin
    $display("############################################################");
    $display("Comenzando el test1");

    sti = new(); 
    assert(sti.randomize()) else $fatal(0,"Randomization failed");  // Ensure randomization is successful
    address = sti.Address;  // Assign the randomized address
    rafagas = sti.bl;       // Assign the randomized burst length

    env.drvr.reset();                      // Apply reset
    env.drvr.burst_write(address, rafagas);  // Perform burst write operation
    #1000;
    env.drvr.burst_read(address, rafagas);   // Perform burst read operation
    #10000;
    
    $finish;  // End simulation
    $display("############################################################");
  end

endprogram
