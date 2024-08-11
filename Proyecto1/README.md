# **Verificación del Controlador SDRAM**

Este proyecto realiza la verificación de un controlador SDRAM utilizando SystemVerilog. El entorno de verificación está organizado en capas, con varios componentes diseñados para trabajar juntos y asegurar el correcto funcionamiento del controlador.

### **Resumen del Proyecto**

| **Componente**      | **Descripción**                                                                                  |
|---------------------|--------------------------------------------------------------------------------------------------|
| **Top-Level Testbench (tb_top)** | Inicializa las señales del sistema, instancia el controlador SDRAM y configura la interfaz de bus. |
| **Environment Class (environment)** | Configura el entorno de simulación creando instancias del driver, scoreboard, y monitor.      |
| **Monitor Class (monitor)**        | Monitorea las señales en el bus para validar las operaciones de escritura y lectura.           |
| **Scoreboard Class (scoreboard)**  | Almacena y rastrea valores para asegurar la integridad de los datos en memoria.                |
| **Driver Class (driver_bus_master)** | Maneja las interacciones con el controladro de la SDRAM, incluyendo operaciones de reset, escritura y lectura.    |
| **Stimulus Class (stimulus)**      | Genera estímulos aleatorios para probar el sistema bajo diferentes condiciones.                |
| **StimulusB Class (stimulusB)**    | Genera estímulos aleatorios específicos para las direcciones de banco, fila y columna.         |
| **Interface (interface_bus_master)** | Define las conexiones para el sistema bus master (Wishbone).               |
| **Test Programs (testcase)**       | Define escenarios de prueba específicos para validar el comportamiento del controlador.            |

### **Detalles del Entorno de Verificación**

- **Top-Level Testbench (tb_top):**  
  Este módulo es el banco de pruebas de nivel superior. Inicializa las señales de reloj del sistema, instancia el controlador SDRAM y conecta el programa de prueba a la interfaz de bus para la simulación. Además, sincroniza los relojes del sistema y SDRAM, y define las señales de interfaz Wishbone y SDRAM para la comunicación con la memoria.

- **Environment Class (environment):**  
  Configura el entorno de simulación creando instancias del driver, scoreboard, y monitor. Conecta estos componentes utilizando la interfaz virtual y ejecuta en paralelo el monitoreo de señales para asegurar que todas las operaciones sean registradas y validadas correctamente.

- **Monitor Class (monitor):**  
  Monitorea continuamente las señales en el bus para rastrear las operaciones de escritura y lectura. Compara los valores observados con los almacenados en el scoreboard para validar la integridad de los datos.

- **Scoreboard Class (scoreboard):**  
  Utiliza un mecanismo de almacenamiento para rastrear las operaciones de escritura y lectura, asegurando que los valores correctos se escriban o lean de la memoria.

- **Driver Class (driver_bus_master):**  
  Implementa el driver para el bus master, manejando interacciones con el SDRAM, incluyendo la realización de operaciones de reset, escritura y lectura en ráfaga.

- **Stimulus Class (stimulus):**  
  Genera estímulos aleatorios para probar el sistema bajo diferentes condiciones, asegurando su correcto funcionamiento.

- **StimulusB Class (stimulusB):**  
  Se especializa en generar estímulos aleatorios para direcciones de banco, fila y columna.

- **Interface (interface_bus_master):**  
  Define las conexiones clave para el sistema bus master, incluyendo relojes y señales de bus para la comunicación con la SDRAM.

- **Test Programs (testcase):**  
  Escenarios de prueba específicos que utilizan las clases del entorno para realizar operaciones de escritura y lectura, verificando el comportamiento del sistema bajo diversas condiciones.

### **Plataforma de Simulación**

Este proyecto fue desarrollado y puede ser ejecutado fácilmente en la plataforma EDA Playground. Puedes acceder al proyecto y ejecutarlo utilizando el siguiente enlace:

🔗 [EDA Playground - Verificación Controlador SDRAM](https://www.edaplayground.com/x/rJYB)

