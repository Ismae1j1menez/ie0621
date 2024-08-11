# **Entorno de Verificación UVM para SDRAM**

Este proyecto implementa un entorno de verificación utilizando el marco UVM (Universal Verification Methodology) para verificar la funcionalidad de un controlador SDRAM. El entorno incluye agentes activos y pasivos, un scoreboard para la verificación de datos, y otros componentes esenciales para asegurar que el controlador funcione correctamente bajo diferentes escenarios de prueba.

### **Descripción General**

| **Componente**      | **Descripción**                                                                                  |
|---------------------|--------------------------------------------------------------------------------------------------|
| **top_hdl.sv** | Archivo de nivel superior que genera las señales de reloj, instancia el DUT y conecta la interfaz UVM. |
| **interface_bus_master.sv** | Define la interfaz utilizada para conectar el bus master con el DUT (Design Under Test).      |
| **sdram_item.sv**        | Clase que representa los elementos transaccionales utilizados en las secuencias UVM.           |
| **sdram_driver.sv**  | Driver responsable de generar estímulos y controlar la interfaz del bus master durante las pruebas. |
| **sdram_monitor_w.sv** | Monitor de escritura que observa las señales del bus y las transmite al scoreboard.    |
| **sdram_monitor_r.sv**      | Monitor de lectura que observa las señales del bus y las transmite al scoreboard.                |
| **sdram_scoreboard.sv**    | Clase que almacena y verifica las transacciones de datos durante las pruebas.         |
| **sdram_agent_active.sv** | Agente activo que incluye el driver, secuenciador y monitor de escritura.               |
| **sdram_agent_passive.sv** | Agente pasivo que incluye el monitor de lectura.               |
| **sdram_env.sv**       | Entorno que integra todos los agentes y componentes necesarios para las pruebas.            |
| **test_1.sv**       | Test que configura el entorno de verificación y ejecuta las secuencias de prueba.            |

### **Estructura de Archivos y Módulos**

- **top_hdl.sv**  
  Archivo que contiene el módulo de nivel superior para el entorno de verificación. Este módulo genera las señales de reloj, instancia el controlador SDRAM (DUT), y conecta la interfaz virtual utilizada por UVM.

- **interface_bus_master.sv**  
  Define la interfaz interface_bus_master utilizada para conectar el bus master con el DUT (Design Under Test). Esta interfaz incluye señales para manejar el protocolo Wishbone y las operaciones de SDRAM.

- **sdram_item.sv**  
  Define la clase sdram_item, que extiende uvm_sequence_item y representa los elementos transaccionales utilizados en las secuencias UVM para interactuar con el DUT.

- **sdram_driver.sv**  
  Contiene la implementación del sdram_driver, que extiende uvm_driver. Este driver es responsable de generar los estímulos y controlar la interfaz del bus master durante las pruebas.

- **sdram_monitor_w.sv**  
  Implementa el monitor de escritura sdram_monitor_w, que observa las señales del bus durante las operaciones de escritura y las transmite al scoreboard para su verificación.

- **sdram_monitor_r.sv**  
  Implementa el monitor de lectura sdram_monitor_r, que observa las señales del bus durante las operaciones de lectura y las transmite al scoreboard para su verificación.

- **sdram_scoreboard.sv**  
  Define la clase sdram_scoreboard, que extiende uvm_component. Este scoreboard almacena y verifica las transacciones de datos que son enviadas y recibidas por el driver y los monitores.

- **sdram_agent_active.sv**  
  Implementa el agente activo sdram_agent_active, que incluye el driver, el secuenciador y el monitor de escritura. Este agente es responsable de generar estímulos y verificar las operaciones de escritura.

- **sdram_agent_passive.sv**  
  Implementa el agente pasivo sdram_agent_passive, que incluye el monitor de lectura. Este agente observa y verifica las operaciones de lectura en el DUT.

- **sdram_env.sv**  
  Define el entorno sdram_env, que extiende uvm_env. Este entorno integra todos los agentes y componentes necesarios para llevar a cabo las pruebas.

- **test_1.sv**  
  Implementa el test test_1, que extiende uvm_test. Este test configura el entorno de verificación, ejecuta las secuencias de prueba, y controla la ejecución de las simulaciones.


### **Plataforma de Simulación**

Este proyecto fue desarrollado y puede ser ejecutado fácilmente en la plataforma EDA Playground. Puedes acceder al proyecto y ejecutarlo utilizando el siguiente enlace:

🔗 [EDA Playground - Verificación Controlador SDRAM - SV/UVM](https://www.edaplayground.com/x/dyVc)

### **Comando de Compilación**

```bash
-timescale=1ns/1ns +vcs+flush+all +warn=all -sverilog +define+S50 +define+VCS  -debug_access+all -cm line+tgl+assert +plusarg_save +UVM_TESTNAME=test_1
```

### Herramientas Utilizadas
El proyecto se verificó utilizando la versión Synopsys VCS 2023.03, como se especifica en el simulador de EDA Playground.
