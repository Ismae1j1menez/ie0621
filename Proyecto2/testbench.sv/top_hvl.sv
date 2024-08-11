/********************************************************************
*  Top-Level Module `top_hvl`
*  This module serves as the entry point for the High-Level Verification (HVL) 
*  environment. It initializes the simulation by invoking the UVM testbench 
*  through the `run_test()` function.
********************************************************************/
import uvm_pkg::*; // Import UVM library, making all UVM classes and functions available.

module top_hvl();

  //------------------------------------------------
  // Initial Block
  // This block starts executing at the beginning of the simulation 
  // and triggers the UVM testbench execution.
  //------------------------------------------------
  initial begin 
    // Call `run_test()` to start the UVM testbench execution.
    // By default, this runs a UVM test named "uvm_test_top".
    run_test();	
  end
  
endmodule
