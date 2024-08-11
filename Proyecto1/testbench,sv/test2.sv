/********************************************************************
*  Test2 Program
*  This program defines another test scenario (Test2) for the system.
*  It uses randomized values for row, bank, and column to perform
*  write and read operations on memory.
********************************************************************/
program testcase(interface_bus_master vif_int);

  //------------------------------------------------
  // Environment and Variables
  // This section creates instances of the environment, stimulusB, 
  // and stimulus classes, and declares necessary variables.
  //------------------------------------------------
  environment env = new(vif_int);
  stimulusB stiB;
  stimulus sti;
  
  reg [7:0] rafagas;
  reg [31:0] address;
  reg [11:0] row;
  reg [1:0] bank;
  reg [7:0] column; 
  
  //------------------------------------------------
  // Initial Block
  // This block defines the sequence of operations for Test2, 
  // including randomization of row, bank, column, and other 
  // parameters, followed by reset, burst write, and burst read.
  //------------------------------------------------
  initial begin
    $display("############################################################");
    $display("Comenzando el test2");

    stiB = new();
    sti = new();
    assert(stiB.randomize()) else $fatal(0,"Randomization failed"); // Ensure randomization of row, bank, column is successful
    assert(sti.randomize()) else $fatal(0,"Randomization failed");  // Ensure randomization of other parameters is successful

    row = stiB.row;          // Assign the randomized row
    bank = stiB.bank;        // Assign the randomized bank
    column = stiB.column;    // Assign the randomized column
    rafagas = sti.bl;        // Assign the randomized burst length
    address = {row, bank, column, 2'b00};  // Construct the address from row, bank, and column

    env.drvr.reset();                      // Apply reset
    env.drvr.burst_write(address, rafagas);  // Perform burst write operation
    #1000;
    env.drvr.burst_read(address, rafagas);   // Perform burst read operation
    #10000;

    $finish;  // End simulation
    $display("############################################################");
  end

endprogram
