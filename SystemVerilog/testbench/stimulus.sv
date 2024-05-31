
class stimulus;
    // Numero aleatorio no repetido de 32 bits
    randc bit [31:0] writte;
    rand bit [7:0] bl;
    randc bit [7:0] amount_times;
    rand bit [31:0] Address;
    rand bit [3:0] command;  // Nuevo campo para command
    rand bit [7:0] delay;    // Nuevo campo para delay
    rand bit [3:0] iterations; // Nuevo campo para iterations
  rand bit [2:0] iteration_write; // Nuevo campo para iterations
  rand bit [2:0] iteration_read; // Nuevo campo para iterations
  

    // Constructor
    function new();
    endfunction

    // Restricciones
    constraint bl_c { bl >= 8 && bl <= 15; }
    constraint amount_times_c { amount_times inside {[1:255]}; }
    constraint command_c { command inside {4'h0, 4'h1, 4'h2, 4'h3}; } 
    constraint delay_c { delay inside {[1:255]}; } // Rango de 1 a 255 para delay
    constraint iterations_c { iterations inside {1, 2, 3, 4}; } 

    // Método para imprimir los valores de la clase
    function void display();
        $display("writte: %h, bl: %0d, amount_times: %0d, Address: %h, command: %0d, delay: %0d, iterations: %0d",
                 writte, bl, amount_times, Address, command, delay, iterations);
    endfunction
endclass

class stimulusB;
    rand bit [11:0] row;
    rand bit [1:0] bank;
    rand bit [7:0] column;

    // Constructor
    function new();
    endfunction

    // Restricciones
    constraint address_c { 
        column inside {[0:255]}; 
        bank inside {0, 1, 2, 3}; 
    }

    // Método para imprimir los valores de la clase
    function void display();
        $display("row: %0d, bank: %0d, column: %0d", row, bank, column);
    endfunction
endclass

