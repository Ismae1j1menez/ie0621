/********************************************************************
*  Stimulus Class
*  This class generates random stimuli for the system, including 
*  various parameters like data, address, command, and timing delays.
********************************************************************/
class stimulus;

    //------------------------------------------------
    // Randomized Fields
    // These fields represent different parameters that 
    // are randomized to generate varied test scenarios.
    //------------------------------------------------
    randc bit [31:0] writte;      // 32-bit random data value, no repeats
    rand bit [7:0] bl;            // Burst length, between 8 and 15
    randc bit [7:0] amount_times; // Random count for certain operations
    rand bit [31:0] Address;      // 32-bit random address
    rand bit [3:0] command;       // Command field, constrained to specific values
    rand bit [7:0] delay;         // Delay value, ranging from 1 to 255
    rand bit [3:0] iterations;    // Number of iterations, between 1 and 4
    rand bit [2:0] iteration_write; // Number of write iterations
    rand bit [2:0] iteration_read;  // Number of read iterations

    //------------------------------------------------
    // Constructor
    // Initializes the stimulus object.
    //------------------------------------------------
    function new();
    endfunction

    //------------------------------------------------
    // Constraints
    // These constraints define valid ranges for the 
    // random fields to ensure meaningful test scenarios.
    //------------------------------------------------
    constraint bl_c { bl >= 8 && bl <= 15; }
    constraint amount_times_c { amount_times inside {[1:255]}; }
    constraint command_c { command inside {4'h0, 4'h1, 4'h2, 4'h3}; } 
    constraint delay_c { delay inside {[1:255]}; }
    constraint iterations_c { iterations inside {1, 2, 3, 4}; } 

    //------------------------------------------------
    // Display Method
    // This method prints the values of the stimulus 
    // fields for debugging and verification purposes.
    //------------------------------------------------
    function void display();
        $display("writte: %h, bl: %0d, amount_times: %0d, Address: %h, command: %0d, delay: %0d, iterations: %0d",
                 writte, bl, amount_times, Address, command, delay, iterations);
    endfunction

endclass

/********************************************************************
*  StimulusB Class
*  This class generates random stimuli for bank, row, and column 
*  addresses, often used in memory testing scenarios.
********************************************************************/
class stimulusB;

    //------------------------------------------------
    // Randomized Fields
    // These fields represent memory address components 
    // that are randomized to create different test cases.
    //------------------------------------------------
    rand bit [11:0] row;        // Randomized row address
    rand bit [1:0] bank;        // Randomized bank address
    rand bit [7:0] column;      // Randomized column address

    //------------------------------------------------
    // Constructor
    // Initializes the stimulusB object.
    //------------------------------------------------
    function new();
    endfunction

    //------------------------------------------------
    // Constraints
    // Defines valid ranges for the row, bank, and 
    // column fields to ensure proper memory addressing.
    //------------------------------------------------
    constraint address_c { 
        column inside {[0:255]}; 
        bank inside {0, 1, 2, 3}; 
    }

    //------------------------------------------------
    // Display Method
    // Prints the values of the stimulusB fields 
    // for debugging and verification purposes.
    //------------------------------------------------
    function void display();
        $display("row: %0d, bank: %0d, column: %0d", row, bank, column);
    endfunction

endclass
