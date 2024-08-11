/********************************************************************
*  Environment Class
*  The environment class sets up the simulation environment by 
*  creating instances of the driver, scoreboard, and monitor. 
*  It connects these components using the virtual interface.
********************************************************************/
class environment;

  //------------------------------------------------
  // Members
  // This section declares the instances of the driver, 
  // scoreboard, monitor, and the virtual interface.
  //------------------------------------------------
  driver_bus_master drvr;              // Instance of the driver
  scoreboard sb;                       // Instance of the scoreboard
  monitor mntr;                        // Instance of the monitor
  virtual interface_bus_master vif_int; // Virtual interface for connecting components
           
  //------------------------------------------------
  // Constructor
  // This constructor initializes the environment by creating 
  // instances of the driver, scoreboard, and monitor, and 
  // starting the monitor's check process.
  //------------------------------------------------
  function new(virtual interface_bus_master vif_int);
    $display("############################################################");
    $display("############################################################");
    $display("-------------------Creating environment---------------------");
    $display("############################################################");

    this.vif_int = vif_int;   // Assign the virtual interface
    sb = new();               // Initialize the scoreboard
    drvr = new(vif_int, sb);  // Initialize the driver with the virtual interface and scoreboard
    mntr = new(vif_int, sb);  // Initialize the monitor with the virtual interface and scoreboard

    fork 
      mntr.check();  // Start the monitor's check process in parallel
    join_none
  endfunction
           
endclass
