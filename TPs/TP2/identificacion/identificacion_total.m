clear all; close all; clc;

s = tf('s');  % Definir variable de Laplace
Ts = 0.01;    % Tiempo de muestreo

% Cargar archivos CSV con mediciones
archivos = {'mediciones_20241009_123201.csv', 'mediciones_20241009_123451.csv', 'mediciones_20241009_130309.csv', 'mediciones_20241009_130426.csv'};
data = {};  % Inicializar celda para datos
for i = 1:length(archivos)     
    data{i} = readtable(archivos{i});  % Leer y almacenar cada archivo
end

% Cargar matriz del péndulo y definir sistema en espacio de estados
load('pendulo_id.mat');
T_pend = tf(ss(A, [0;1], [1,0], 0));

% Cargar transferencia del servo
load('servo_id2.mat');

% Definir G_monio como la planta multiplicada por el servo y s^2
G_monio = T_pend * T_servo2 * s^2;

% Incluir retardo Td
Td = 0.06;
G_monio = G_monio * exp(-Td * s);


% Estimar ganancia k usando pseudoinversa
theta = []; theta_sim = [];
for i = 1:length(archivos)
    time = data{i}.t(100:end);
    u = data{i}.u(100:end);
    u_sim = u(end) * heaviside(time - 1.00);
    y = lsim(G_monio, u_sim, time);  % Simular respuesta
    theta_sim = [theta_sim; y];
    theta = [theta; data{i}.theta(100:end)];
end
k = pinv(theta_sim) * theta;  % Calcular k
G = k * G_monio;              % Ajustar planta con k

% Crear sistema en espacio de estados de la Planta
num_servo = T_servo2.numerator{:};
den_servo = T_servo2.denominator{:};

A = [0, 1, 0, 0;
     A(2,1), A(2,2), -k * den_servo(3), -k * den_servo(2);
     0, 0, 0, 1;
     0, 0, -den_servo(3), -den_servo(2)];
B = [0, k * num_servo(3), 0, num_servo(3)]';
C = [1, 0, 0, 0];
D = [0];

planta_ss = ss(A, B, C, D);  % Sistema en espacio de estados

% Simulación y gráfico comparativo
i = 1;  
time = data{i}.t(1:end);
u = data{i}.u(1:end);
theta = data{i}.theta(1:end);

u_sim = u(end) * heaviside(time - 1.0);
[theta_sim, t_sim] = lsim(G, u_sim, time);

% Graficar simulación vs mediciones
figure('Position', [300, 300, 800, 400]); hold on;
plot(t_sim, theta_sim, 'DisplayName', 'Simulación: u(t) = \pi/6 h(t-1)');
plot(time, theta, 'DisplayName', 'Medición: u(t) = \pi/6 h(t-1)');

legend;
grid on;
xlabel('t [s]');
ylabel('\theta [rad]');
