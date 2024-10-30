clear all; close all; clc;

% Lista de archivos CSV que contienen las mediciones
archivos = {
    'mediciones_20241009_123201.csv', 
    'mediciones_20241009_123451.csv', 
    'mediciones_20241009_130309.csv',  
    'mediciones_20241009_130426.csv'
};

% Inicializar una celda para almacenar los datos
Data = cell(length(archivos), 1);

% Leer los archivos CSV y almacenar los datos en la celda
for i = 1:length(archivos)     
    med = readtable(archivos{i});  % Leer el archivo actual
    Data{i} = med;                  % Almacenar los datos en la celda
end

% Cargo la funcion de transferencia del servo
load('servo_id2.mat');
load('servo_id1.mat');

% Graficar las respuestas del sistema
figure(); hold on;
for i = 1:length(archivos)     
    t = Data{i}.t(1:end);          % Tiempo
    u = Data{i}.u(1:end);          % Entrada
    phi = Data{i}.phi(1:end);      % Salida
    
    % Definir la entrada simulada como un escalón
    u_sim = u(end) * heaviside(t - 1.03);
    
    % Simular la salida usando la función de transferencia
    phi_sim1 = lsim(T_servo1, u_sim, t);
    phi_sim2 = lsim(T_servo2, u_sim, t);
    
    % Graficar la salida simulada y la medida
    plot(t(1:400), phi_sim1(1:400), 'DisplayName', ['Simulación Id1_', num2str(i)]);    
    plot(t(1:400), phi_sim2(1:400), 'DisplayName', ['Simulación Id2_', num2str(i)]);
    plot(t(1:400), phi(1:400), 'DisplayName', ['Medición ', num2str(i)]);
end
legend;