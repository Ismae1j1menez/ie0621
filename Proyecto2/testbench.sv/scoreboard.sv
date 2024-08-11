/********************************************************************
*  Class `sdram_scoreboard`
*  This class extends `uvm_component` and acts as a scoreboard within 
*  the verification environment. It is responsible for storing and 
*  verifying data transactions sent and received by the driver and monitor.
********************************************************************/
`uvm_analysis_imp_decl(_drv) // Declare analysis port for the driver
`uvm_analysis_imp_decl(_mon) // Declare analysis port for the monitor

class sdram_scoreboard extends uvm_component;

  //------------------------------------------------
  // UVM Class Registration
  // Macro to register the `sdram_scoreboard` class with UVM.
  //------------------------------------------------
  `uvm_component_utils(sdram_scoreboard)
  
  //------------------------------------------------
  // Constructor
  // Initializes the scoreboard with a name and an optional parent component.
  //------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //------------------------------------------------
  // Analysis Port Declarations
  // These ports receive items from the driver and monitor 
  // for verification and storage.
  //------------------------------------------------
  uvm_analysis_imp_drv #(sdram_item, sdram_scoreboard) sb_drv;
  uvm_analysis_imp_mon #(sdram_item, sdram_scoreboard) sb_mon;
  
  //------------------------------------------------
  // Build Phase
  // Creates instances of the analysis ports to connect 
  // the driver and monitor to the scoreboard.
  //------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_drv = new("sb_drv", this); // Instantiate analysis port for the driver
    sb_mon = new("sb_mon", this); // Instantiate analysis port for the monitor
  endfunction

  //------------------------------------------------
  // Data Structure
  // Defines a structure to store memory operations, 
  // including the address, data, and write enable signal.
  //------------------------------------------------
  typedef struct {
    bit [31:0] address;       // Memory address affected
    bit [31:0] data;          // Data involved in the operation
    bit        write_enable;  // Indicates if the write operation has already been executed
  } data_t;

  //------------------------------------------------
  // Data Dictionary
  // Uses a dictionary to store memory operations, 
  // indexed by address.
  //------------------------------------------------
  data_t dict[bit[31:0]];
  
  //------------------------------------------------
  // Function to Add an Entry
  // Stores a new entry in the dictionary using the address 
  // as the key and logs the operation.
  //------------------------------------------------
  function void add_entry(bit[31:0] id, bit[31:0] address, bit [31:0] data, bit write_enable);
    data_t new_data;
    new_data.address = address;
    new_data.data = data;
    new_data.write_enable = write_enable;
    dict[id] = new_data; // Store the new entry
    `uvm_info("SCOREBOARD", $sformatf("Adding Entry - ID %h: Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable), UVM_LOW)
  endfunction

  //------------------------------------------------
  // Function to Find an Entry
  // Searches for a specific entry in the dictionary using the address 
  // as the key and returns the associated data.
  //------------------------------------------------
  function bit find_entry(bit[31:0] id, output bit[31:0] address, output bit[31:0] data, output bit write_enable);
    if (dict.exists(id)) begin 
      address = dict[id].address;
      data = dict[id].data;
      write_enable = dict[id].write_enable;
      return 1; 
    end else begin
      return 0; 
    end
  endfunction
  
  //------------------------------------------------
  // Function to Iterate over the Dictionary
  // Iterates and displays all entries stored in the dictionary.
  //------------------------------------------------
  function void iterate();
    foreach(dict[id]) begin 
      `uvm_info("SCOREBOARD", $sformatf("ID: %h, Address: %h, Data: %h, Write Enable: %b", id, dict[id].address, dict[id].data, dict[id].write_enable), UVM_LOW)
    end
  endfunction

  //------------------------------------------------
  // Function `write_drv`
  // Called by the driver to add new entries to the dictionary 
  // when a write operation is performed.
  //------------------------------------------------
  function void write_drv(sdram_item t);
    add_entry(t.Address, t.Address, t.writte, t.command); 
    iterate();
  endfunction
	
  //------------------------------------------------
  // Function `write_mon`
  // Called by the monitor to verify the operations performed 
  // and compare the data with what is stored in the dictionary.
  //------------------------------------------------
  function void write_mon(sdram_item t);
    bit [31:0] addr;
    bit [31:0] dat;
    bit        we;
    if (find_entry(t.Address, addr, dat, we)) begin 
      if (addr == t.Address && dat == t.writte) begin 
        `uvm_info("SCOREBOARD", $sformatf("Entry matches - Passed - Address: %h, Data: %h", addr, dat), UVM_LOW)
      end
    end
  endfunction

endclass
