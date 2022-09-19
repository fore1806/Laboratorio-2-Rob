# Laboratorio-2- Robótica de Desarrollo, Intro a ROS
 
Segundo laboratorio de la asignatura Robótica de la Universidad Nacional de Colombia en su sede Bogotá.
 
## Autores
 
|              Nombre              |GitHub nickname|
|----------------------------------|---------------|
| Nikolai Alexnder Caceres Penagos |[nacaceresp](https://github.com/nacaceresp)|
|    Andrés Felipe Forero Salas    |[fore1806](https://github.com/fore1806)|
|  Iván Mauricio Hernández Triana  |[elestrategaactual](https://github.com/elestrategaactual)|
 
## Introducción
 
La realización de diferentes proyectos bajo el entorno de ROS posee gran importancia en el adelanto de proyectos relacionados con la robótica de desarrollo. Esto es debido a que ROS está basado en una arquitectura de grafos donde el procesamiento toma lugar en los nodos que pueden recibir, mandar y multiplexar mensajes de sensores, control, estados, planificaciones y actuadores, entre otros. Por esto se convierte en una necesidad dentro de la formación profesional de un ingeniero mecatrónico el conocer el manejo de ROS. De esta forma, mediante la realización de este laboratorio, se genera un primer acercamiento a la programación e integración de diferentes nodos en ROS a través del programa de turtleSim.
 
## Solución planteada.
 
### Configuración inicial
Esta configuración inicial se realizó siguiendo la guía disponible en el siguiente enlace [rob_unal_clase2](https://github.com/fegonzalez7/rob_unal_clase2) en el cual se puede consultar los pasos para la configuración inicial de Linux para la instalación de ROS, así como otras herramientas recomendadas. A su vez, aquí se puede encontrar la forma de inicializar turtlesim, para lo cual se deben emplear 3 terminales, en la primera de ellas se debe inicializar el nodo maestro de ROS utilizando el comando a continuación.

```
roscore
```

En la segunda terminal, se inicia el simulador de turtlesim, utilizando el siguiente comando.

```
rosrun turtlesim turtlesim_node
```
Con lo que se inicializa el nodo de la tortuga; finalmente en la tercera terminal se abre la aplicación de MATLAB, para lo que simplemente debe escribirse el nombre del software.

```
matlab
```

Una vez en MATLAB, se debe realizar la conexión con el nodo maestro de ROS; sin embargo, el equipo de trabajo por prácticas de seguridad comienza el código finalizando cualquier conexión con nodo maestro existente. Para esto, se debe contar con el [Robotics System Toolbox](https://la.mathworks.com/products/robotics.html), disponible para versiones recientes del software de MATLAB.

```Matlab
rosshutdown; 
rosinit; %conexión con nodo maestro
```
Posterior a esto, se debe crear un publicador y un mensaje, que nos permitirán enviar a la tortuga instrucciones de movimiento lineal y angular.

```Matlab
velPub = rospublisher('/turtle1/cmd_vel','geometry_msgs/Twist'); %Creación publicador
velMsg = rosmessage(velPub); %Creación de mensaje
```
Finalmente, se deben crear dos servicios de turtlesim para mover instantáneamente la tortuga, comandos asociados a la tecla r, y a la tecla espacio. La configuración de los servicios y los request de los mismos, se realizan en base a la documentación de MATLAB disponible en el enlace [Call and Provide ROS Services](https://la.mathworks.com/help/ros/ug/call-and-provide-ros-services.html)

```Matlab
testclient = rossvcclient('/turtle1/teleport_absolute','DataFormat','struct');
testreq  = rosmessage(testclient);
testclient2 = rossvcclient('/turtle1/teleport_relative','DataFormat','struct');
testreq2  = rosmessage(testclient2);
```
### Código Solución

Para establecer la solución del laboratorio, se debía pensar de manera iterativa la recepción de comandos por parte del usuario, esto hace necesaria la presencia de un ciclo infinito que nos permita actualizar el valor de lectura. La lectura de las teclas pulsadas supuso un reto para el equipo de trabajo dado que al explorar diferentes funciones incluidas en MATLAB, sólo se permitía realizar una lectura del teclado, y no permitía resetear dicha lectura, por lo que no se lograba controlar la tortuga con el teclado.

Este problema fue solucionado al encontrar un Add on del software llamado getkey, disponible en el enlace [getkey](https://la.mathworks.com/matlabcentral/fileexchange/7465-getkey), que permite fácilmente almacenar y resetear el valor entregado por el usuario a través del teclado del computador. Para el caso de esta implementación, se almacena el valor leído en la variable tecla, a través de la siguientee línea de código.

```Matlab
tecla = getkey;
```
Una vez, almacenado el valor de la tecla presionada por el usuario, se debe realizar un cast que permita al sistema saber que tarea debe ejecutar, según la tabla.


| Tecla | Operación                        |
| -- | -- |
|W,↑    | Mover al frente                  |
|S,↓    | Mover atras                      |
|A,←    | Girar sentido de las manecillas  |
|D,→    | Girar contrario de las manecillas|
|R      | Regresar al origen               |
|espacio| Girar 180°                       |


Para el caso de los primeros cuatro comandos, se utiliza el publicador creado con anterioridad, para enviar al nodo de la tortuga lo que debe hacer, en los primeros dos casos, se debe modificar el parámetro *Linear* dentro del struct *velMsg* creado; mientras que en los casos subsecuentes, se debe modificar el parámetro *Angular* de dicho struct. Los mensajes son enviados con ayuda del comando send con parámetros el Publisher y el mensaje.

Finalmente, para las teclas espacio y R, se debe modificar el struct que hace el request al servicio del turtlesim, estos también son almacenados en MATLAB en formato struct, con una pequeña particularidad y es que es de tipo *single*, lo que hace necesario realizar el cast de tipos de datos para ser aprovechables para el comando. La solicitud del servicio se realiza, con la ayuda del comando call de MATLAB, con parámetros el cliente, el request y se deja un pequeño Timeout para la ejecución del servicio.

El código que realiza la verificación de la tecla pulsada y que realiza el envió de órdenes, se puede visualizar a continuación.
```Matlab
    if (tecla=='w' | tecla=='W' | tecla==30)
        velMsg.Linear.X = 1; %Valor del mensaje
        send(velPub,velMsg); %Envio
    elseif (tecla=='s' | tecla=='S' | tecla==31)
        velMsg.Linear.X = -1; %Valor del mensaje
        send(velPub,velMsg); %Envio
    elseif (tecla=='a' | tecla=='A' | tecla==28)
        velMsg.Angular.Z = 0.1; %Valor del mensaje
        send(velPub,velMsg); %Envio
    elseif (tecla=='d' | tecla=='D' | tecla==29)
        velMsg.Angular.Z = -0.1; %Valor del mensaje
        send(velPub,velMsg); %Envio
    elseif (tecla==' ')
        testreq2.Linear = cast(0,'single');
        testreq2.Angular = cast(pi,'single');
        call(testclient2,testreq2,"Timeout",3)
    elseif (tecla=='r'| tecla=='R')
        testreq.X = cast(5.544445,'single');
        testreq.Y = cast(5.544445,'single');
        testreq.Theta = cast(0,'single');
        call(testclient,testreq,"Timeout",3)
    end
```
### Simulación

El proceso es simulado, siguiendo el procedimiento explicado en la sección de Configuración Inicial, como se evidencia en el video mostrado a continuación.

[![Alt text](https://github.com/fore1806/Laboratorio-2-Rob/blob/main/imagenes/videolab2.png)](https://www.youtube.com/watch?v=XTEBdVZ-wiE)


## Conclusiones

- Se evidencia el gran potencial que tiene MATLAB, para trabajar con ROS utilizando los diferentes plugins con los que cuenta el software.

- Se observó la falta de desarrollo de aplicaciones en ROS utilizando el programa MATLAB, lo que dificulta encontrar guías base para realizar este tipo de ejercicios didácticos de aprendizaje.

- Se encuentra un correcto funcionamiento del programa desarrollado en MATLAB para mover la tortuga en base a las especificaciones requeridas por el laboratorio.
