clear all; close all; clc;

% Configuración del Bode
my_bode_options = bodeoptions;
my_bode_options.PhaseMatching = 'on';
my_bode_options.PhaseMatchingFreq = 1;
my_bode_options.PhaseMatchingValue = -180;
my_bode_options.Grid = 'on';


s = tf('s');  % Definir variable de Laplace
Ts = 0.01;    % Tiempo de muestreo

% Cargar archivos CSV con mediciones
archivos = {
    'mediciones_20241022_145537.csv', 
    'mediciones_20241022_150820.csv', 
    'mediciones_20241022_150642.csv',  
    'mediciones_20241022_145810.csv'};

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
G_nodelay = G_monio;
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
G_nodelay = k * G_nodelay;

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

legends = {'u(t) = \pi/6 h(t-1)','u(t) = -\pi/6 h(t-1)','u(t) = -\pi/9 h(t-1) ','u(t) = \pi/9 h(t-1)'};

figure('Position',[300,300,800,400]); hold on;
% Simulación y gráfico comparativo
for i=1:length(data)
subplot(2,2,i); hold on

time = data{i}.t(1:end);
u = data{i}.u(1:end);
theta = data{i}.theta(1:end);

u_sim = u(end) * heaviside(time - 1.0);
[theta_sim, t_sim] = lsim(G, u_sim, time);

error_po(i) = mean((theta(1:500)-theta_sim(1:500)).^2) / mean((theta(1:500)).^2) * 100;
error_uo(i) = mean((theta(500:end)-theta_sim(500:end)).^2) / mean((theta(500:end)).^2) * 100;

% Graficar simulación vs mediciones

plot(t_sim, theta_sim,'LineWidth',1.5, 'DisplayName', ['Simulación:',legends{i}]);
plot(time, theta,'LineWidth',1.5, 'DisplayName', ['Medición: ',legends{i}]);

legend;
grid on;
xlabel('t [s]');
ylabel('\theta [rad]');
end

%%
figure('Position',[300,300,800,400]); hold on;
% Simulación y gráfico comparativo
for i=1:1
time = data{i}.t(1:end);
u = data{i}.u(1:end);
theta = data{i}.theta(1:end);
theta(101) = 0;
theta(102) = 0;
theta(103) = 0;
theta(104) = 0;
theta(105) = 0;
theta(106) = 0;
theta(107) = 0;
theta(108) = -0.002;

u_sim = u(end) * heaviside(time - 1.0);
[theta_sim, t_sim] = lsim(G, u_sim, time);

error_po(i) = mean((theta(1:500)-theta_sim(1:500)).^2) / mean((theta(1:500)).^2) * 100;
error_uo(i) = mean((theta(500:end)-theta_sim(500:end)).^2) / mean((theta(500:end)).^2) * 100;

% Graficar simulación vs mediciones

%plot(t_sim, theta_sim,'LineWidth',1.5, 'DisplayName', ['Simulación:',legends{i}]);
plot(time, theta,'LineWidth',1.5, 'DisplayName', ['Medición: ',legends{i}]);

legend;
grid on;
xlabel('t [s]');
ylabel('\theta [rad]');
end


%%
close all
% Diagramas de bode
figure(); hold on
bode(-G_nodelay,my_bode_options)
bode(-G*exp(-Ts/2 * s),my_bode_options)
bode(pade(-G*exp(-Ts/2 * s)),my_bode_options)
legend('Sin retardo','Exacto', 'Aproximación Padé');

figure(); hold on
% Rango de frecuencias (rad/s)
w = logspace(-1, 3, 1000); % De 10^-1 a 10^3 con 1000 puntos

bode(exp(-(Ts/2 + Td) * s), w,my_bode_options); % Bode de la función exponencial
bode(pade(exp(-(Ts/2 + Td) * s), 1), w,my_bode_options); % Aproximación de Padé
legend('Exacto', 'Aproximación Padé');

save('planta_id','G','G_nodelay', 'Td')

