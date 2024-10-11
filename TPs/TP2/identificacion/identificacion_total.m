clear variable
close all
clc

s = tf('s');

% Leer el archivo CSV como una matriz (sin encabezados)
data = readtable('mediciones_20241006_100053.csv');

load('pendulo_id.mat');
load('servo_id.mat');

% Mostrar los primeros datos
time = data.t(101:end)-1;
theta = data.theta(101:end)*pi/180;


% Valores de k
k_values = -350:50:-300;

k = -330;
% Crear una nueva figura
figure;
hold on;
%{
% Evaluar para cada valor de k
for k = k_values
    % Definir matrices del sistema
    A_tot = [0 0 1 0; 
             0 0 0 1; 
             -a/c 0 -b/c 0; 
             0 A(2,1) -k A(2,2)];
    B_tot = [0 0 -a 0]';
    C_tot = [0 1 0 0];
    D_tot = 0;

    % Crear el sistema de espacio de estados
    planta_ss = ss(A_tot, B_tot, C_tot, D_tot);
    
    % Simular y graficar la respuesta al escalón
    opts = stepDataOptions('StepAmplitude',35*pi/180);
    [y, t] = step(planta_ss,opts);
    plot(t, y, 'DisplayName', ['k = ' num2str(k)]);
end
%}

% Definir matrices del sistema
A_tot = [0 0 1 0; 0 0 0 1; -a/c 0 -b/c 0; 0 A(2,1) -k A(2,2)];
B_tot = [0 0 -a 0]';
C_tot = [0 1 0 0];
D_tot = 0;

% Crear el sistema de espacio de estados
planta_ss = ss(A_tot, B_tot, C_tot, D_tot);
P = tf(planta_ss) * exp(-s*0.005);
% Simular y graficar la respuesta al escalón
opts = stepDataOptions('StepAmplitude',35*pi/180);
[y, t] = step(P,opts);
plot(t, y, 'DisplayName', ['k = ' num2str(k)]);


% Respuesta al escalon real
plot(time,theta,'DisplayName',['Rta Real']);

% Configurar la gráfica
title('Respuesta al escalón para diferentes valores de k');
xlabel('Tiempo (s)');
ylabel('Salida');
legend('show');
grid on;
hold off;
