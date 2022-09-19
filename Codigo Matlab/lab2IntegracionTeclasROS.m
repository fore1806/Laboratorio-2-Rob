%%%%%%%%%%%%%%%%AUTORES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% |              Nombre              |                    GitHub nickname                      |
% | Nikolai Alexnder Caceres Penagos |          [nacaceresp](https://github.com/nacaceresp)    |
% |    Andrés Felipe Forero Salas    |[fore1806](https://github.com/fore1806)                  |
% |  Iván Mauricio Hernández Triana  |[elestrategaactual](https://github.com/elestrategaactual)|
%%

rosshutdown;
rosinit; %Conexi ́on con nodo maestro
%%
velPub = rospublisher('/turtle1/cmd_vel','geometry_msgs/Twist'); %Creaci ́on publicador
velMsg = rosmessage(velPub); %Creaci ́on de mensaje

testclient = rossvcclient('/turtle1/teleport_absolute','DataFormat','struct');
testreq  = rosmessage(testclient);

testclient2 = rossvcclient('/turtle1/teleport_relative','DataFormat','struct');
testreq2  = rosmessage(testclient2);

%%
while(1)
    tecla = getkey;

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
    tecla = 0;
    pause(1)
    
end