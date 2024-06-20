`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)

class sdram_scoreboard extends uvm_component;
  `uvm_component_utils(sdram_scoreboard)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  uvm_analysis_imp_drv #(arb_item, sdram_scoreboard) sb_drv;
  uvm_analysis_imp_mon #(arb_item, sdram_scoreboard) sb_mon;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_drv = new("sb_drv", this);
    sb_mon = new("sb_mon", this);
  endfunction

  typedef struct {
    bit [31:0] address;
    bit [31:0] data;
    bit write_enable;
  } data_t;

  data_t dict[bit[31:0]];
  
  function void add_entry(bit[31:0] id, bit[31:0] address, bit [31:0] data, bit write_enable);
    data_t new_data;
    new_data.address = address;
    new_data.data = data;
    new_data.write_enable = write_enable;
    dict[id] = new_data;
    `uvm_info("SCOREBOARD", $sformatf("Adding Entry - ID %h: Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable), UVM_LOW)
  endfunction

  function bit find_entry(bit[31:0] id, output bit[31:0] address, output bit[31:0] data, output bit write_enable);
    if (dict.exists(id)) begin
      address = dict[id].address;
      data = dict[id].data;
      write_enable = dict[id].write_enable;
      `uvm_info("SCOREBOARD", $sformatf("Entry found - ID %h: Address: %h, Data: %h, Write Enable: %b", id, address, data, write_enable), UVM_LOW)
      return 1;
    end else begin
      `uvm_info("SCOREBOARD", $sformatf("No entry found for ID %h", id), UVM_LOW)
      return 0;
    end
  endfunction

  function bit [31:0] get_unread_entry();
    foreach (dict[id]) begin
      if (dict[id].write_enable == 1) begin
        bit [31:0] address = dict[id].address;
        dict[id].write_enable = 0;
        `uvm_info("SCOREBOARD", $sformatf("Unread entry found - ID %h: Address: %h", id, address), UVM_LOW)
        return address;
      end
    end
    `uvm_info("SCOREBOARD", "No unread entry found", UVM_LOW)
    return '0;
  endfunction

  function void iterate();
    foreach(dict[id]) begin
      `uvm_info("SCOREBOARD", $sformatf("ID: %h, Address: %h, Data: %h, Write Enable: %b", id, dict[id].address, dict[id].data, dict[id].write_enable), UVM_LOW)
    end
  endfunction

  function void write_drv(arb_item t);
    add_entry(t.Address, t.Address, t.writte, t.command);
    iterate();
  endfunction
	
  function void write_mon(arb_item t);
    bit [31:0] addr;
    bit [31:0] dat;
    bit we;
    if (find_entry(t.Address, addr, dat, we)) begin
      `uvm_info("SCOREBOARD", $sformatf("Entry matches - Address: %h, Data: %h, Write Enable: %b", addr, dat, we), UVM_LOW)
    end else begin
      `uvm_info("SCOREBOARD", $sformatf("No matching entry found for Address: %h", t.Address), UVM_LOW)
    end
  endfunction

endclass
