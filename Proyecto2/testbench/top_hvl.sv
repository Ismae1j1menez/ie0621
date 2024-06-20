// Import UVM library. This command makes all UVM classes and functions available for use.
import uvm_pkg::*;

// Define the top-level module for the HVL (High-Level Verification) environment.
module top_hvl();

// 'initial' block starts executing at the beginning of the simulation.
initial begin 
  // Call 'run_test()' which is a UVM method to start the testbench execution.
  // This function without arguments defaults to running a UVM test named "uvm_test_top",
  // which must be set up in your UVM environment's test classes.
  run_test();	
end
  
endmodule
