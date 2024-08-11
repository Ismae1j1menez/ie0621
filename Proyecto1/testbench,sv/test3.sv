/********************************************************************
*  Test3 Program
*  This test scenario (Test3) introduces randomness in the number 
*  of write and read operations by using the randomized variables 
*  iteration_write and iteration_read to ensure the counts are different.
********************************************************************/
program testcase(interface_bus_master vif_int);

  //------------------------------------------------
  // Environment and Variables
  // This section creates instances of the environment and stimulus 
  // classes and declares necessary variables, including iterations.
  //------------------------------------------------
  environment env = new(vif_int);
  stimulus sti;
  reg [7:0] rafagas;
  reg [31:0] address;
  reg [2:0] iteration_write; // Variable to control the number of write iterations
  reg [2:0] iteration_read;  // Variable to control the number of read iterations
  
  //------------------------------------------------
  // Initial Block
  // This block defines the sequence of operations for Test3, 
  // including randomization of parameters, and performing 
  // write and read operations with different iteration counts.
  //------------------------------------------------
  initial begin
    $display("############################################################");
    $display("Comenzando el test3");

    sti = new(); 
    assert(sti.randomize()) else $fatal(0,"Randomization failed");  // Ensure randomization is successful
    address = sti.Address;       // Assign the randomized address
    rafagas = sti.bl;            // Assign the randomized burst length
    iteration_write = sti.iteration_write;  // Assign the randomized write iteration count
    iteration_read = sti.iteration_read;    // Assign the randomized read iteration count

    env.drvr.reset();                            // Apply reset
    env.drvr.burst_write(address, rafagas + iteration_write);  // Perform burst write with additional iterations
    #1000;
    env.drvr.burst_read(address, rafagas + iteration_read);    // Perform burst read with additional iterations
    #10000;

    $finish;  // End simulation
    $display("############################################################");
  end

endprogram
