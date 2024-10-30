clear all; close all; clc;

s = tf('s');

% Lista de archivos CSV que contienen las mediciones
archivos = {
    'mediciones_20241009_123201.csv', 
    'mediciones_20241009_123451.csv', 
    'mediciones_20241009_130309.csv',  
    'mediciones_20241009_130426.csv'
};
Ts = 0.01;  % Tiempo de muestreo, asumido constante entre experimentos

% Inicializar el objeto 'iddata' utilizando el primer conjunto de datos
med = readtable(archivos{1});  % Leer el primer archivo
u = med.u(1:400);               % Extraer la entrada (control) del archivo
y = med.phi(1:400);             % Extraer la salida (respuesta del sistema)
data_id = iddata(y, u, Ts);    % Crear el objeto iddata con los datos del primer archivo

% Bucle para combinar los conjuntos de datos restantes
for i = 2:length(archivos)      % Comenzar desde el segundo archivo
    med = readtable(archivos{i});  % Leer el archivo actual
    u = med.u(1:200);               % Extraer la entrada del archivo
    y = med.phi(1:200);             % Extraer la salida del archivo
    new_data = iddata(y, u, Ts);    % Crear el objeto iddata para los datos actuales
    
    % Combinar el nuevo conjunto de datos con el existente
    data_id = merge(data_id, new_data);
end

% Paso 3: Estimar la función de transferencia de orden 2 y el delay
n_polos = 2;  % Número de polos en el modelo a estimar
n_ceros = 0;  % Número de ceros en el modelo a estimar
sys_est = tfest(data_id, n_polos, n_ceros);  % Estimar el modelo de transferencia

delay_samples = delayest(data_id)-2;

T_servo1 = tf(sys_est) ;

% Paso 4: Validar el modelo estimado comparando la salida simulada con la salida experimental
% Grafico comparacion 1
figure;                            % Crear una nueva figura
compare(data_id, sys_est);        % Comparar la salida experimental con la del modelo estimado
title('Comparación de la salida experimental vs. el modelo estimado');  % Título de la gráfica

% Grafico comparacion 2
figure('Position',[300,300,800,400]); hold on
med = readtable(archivos{1});  
u = med.u(1:400);               
phi = med.phi(1:400);             
t = med.t(1:400);

phi_sim = lsim(T_servo1,u,t);
plot(t,phi_sim,'LineWidth',2,'DisplayName','Simulacion: Modelo estimado tfest()');
plot(t,phi,'LineWidth',2,'DisplayName', 'Medicion');

grid on
xlabel('t [s]')
ylabel('\phi [rad]')
legend('Location','Southeast')

save('servo_id1','T_servo1')
