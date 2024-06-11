class environment;
  driver_bus_master drvr;
  scoreboard sb;
  monitor mntr;
  virtual interface_bus_master vif_int;
           
  function new(virtual interface_bus_master vif_int);
    $display("############################################################");
    $display("############################################################");
    $display("-------------------Creating environment---------------------");
    $display("############################################################");
    this.vif_int = vif_int;
    sb = new();
    drvr = new(vif_int,sb);
    mntr = new(vif_int,sb);
    fork 
      mntr.check();
    join_none
  endfunction
           
endclass
