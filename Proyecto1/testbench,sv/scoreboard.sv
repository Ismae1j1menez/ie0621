/********************************************************************
*  Scoreboard Class
*  This class is used to store and track the values of addresses, 
*  data, and write enable signals. It provides methods to add, 
*  find, and iterate over the stored entries, ensuring that the 
*  correct values are written to or read from memory.
********************************************************************/
class scoreboard;

  //------------------------------------------------
  // Data Structure
  // This section defines a structure to store the 
  // address, data, and write enable signals together.
  //------------------------------------------------
  typedef struct {
    bit [31:0] address;      // Address value
    bit [31:0] data;         // Data value
    bit        write_enable; // Write enable signal
  } data_t;

  //------------------------------------------------
  // Dictionary (Array)
  // This section defines a dictionary to store the data_t 
  // structure, indexed by a 32-bit ID, allowing for easy lookup.
  //------------------------------------------------
  data_t dict[bit[31:0]];

  //------------------------------------------------
  // Method: add_entry
  // This method adds a new entry to the dictionary. If the 
  // entry already exists, it updates the existing entry.
  //------------------------------------------------
  function void add_entry(bit[31:0] id, bit[31:0] address, bit[31:0] data, bit write_enable);
    data_t new_data;
    new_data.address = address;
    new_data.data = data;
    new_data.write_enable = write_enable;
    dict[id] = new_data;  // Add or update the entry in the dictionary
    $display("Adding Entry - ID %h: Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable);
  endfunction

  //------------------------------------------------
  // Method: find_entry
  // This method searches the dictionary for an entry by its ID. 
  // If found, it returns the associated address, data, and 
  // write enable values; otherwise, it returns 0.
  //------------------------------------------------
  function bit find_entry(bit[31:0] id, output bit[31:0] address, output bit[31:0] data, output bit write_enable);
    if (dict.exists(id)) begin
      address = dict[id].address;
      data = dict[id].data;
      write_enable = dict[id].write_enable;
      $display("Entry found - ID %h: Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable);
      return 1;  // Entry found
    end else begin
      $display("No entry found for ID %h:", id);
      return 0;  // Entry not found
    end
  endfunction

  //------------------------------------------------
  // Method: iterate
  // This method iterates over all entries in the dictionary and 
  // displays the stored address, data, and write enable values.
  //------------------------------------------------
  function void iterate();
    foreach(dict[id]) begin
      $display("ID: %d, Address: %h, Data: %h, Write Enable: %b", id, dict[id].address, dict[id].data, dict[id].write_enable);
    end
  endfunction

endclass
