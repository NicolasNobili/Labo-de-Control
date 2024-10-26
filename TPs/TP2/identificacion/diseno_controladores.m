close all; clear all; clc;
s = tf('s');

% Cargo la planta completa estimada
load('planta_id');
Ts = 0.01;

G_pade = pade(G * exp(-Ts*s/2));

figure(); hold on
bode(G_pade);

% Configuración del Bode
my_bode_options = bodeoptions;
my_bode_options.PhaseMatching = 'on';
my_bode_options.PhaseMatchingFreq = 1;
my_bode_options.PhaseMatchingValue = -180;
my_bode_options.Grid = 'on';


%%
close all; clc;
% Respuesta de salida Theta ante escalon u
% Lista de archivos CSV que contienen las mediciones
archivos = {
    'mediciones_20241009_123201.csv', 
    'mediciones_20241009_123451.csv', 
    'mediciones_20241009_130309.csv',  
    'mediciones_20241009_130426.csv'
};

% Inicializar celda para almacenar los datos
Data = cell(length(archivos), 1);

% Leer los archivos CSV y almacenar los datos
for i = 1:length(archivos)
    med = readtable(archivos{i});  % Leer archivo
    Data{i} = med;                 % Guardar en celda
end



legends = {'u(t) = \pi/6 h(t-1)','u(t) = -\pi/6 h(t-1)','u(t) = -\pi/9 h(t-1) ','u(t) = \pi/9 h(t-1)'};
for i = 1:length(archivos)
    t = Data{i}.t(1:end);          % Tiempo
    u = Data{i}.u(1:end);          % Entrada
    phi = Data{i}.phi(1:end);      % Salida
    theta = Data{i}.theta(1:end);      % Salida
    
    % Definir entrada simulada (escalón)
    u_sim = u(end) * heaviside(t - 1.03);
    
    % Simular la salida usando la función de transferencia
    theta_sim = lsim(G, u_sim, t);
    figure('Position',[300,300,800,400]); hold on;
    % Graficar salida simulada y medida
    plot(t(1:400), theta_sim(1:400),'LineWidth',2, 'DisplayName', ['Simulación ',': ',legends{i}]);
    plot(t(1:400), theta(1:400),'LineWidth',1.5, 'DisplayName', ['Medición ',': ',legends{i}]);
    
    % Personalización de la gráfica
    legend('Location','east');
    grid on;
    title('Respuesta al escalón')
    xlabel('t [s]')
    ylabel('\theta [rad]')
end


%%
% Controlador proporcional
close all; clc;

archivos = {'impulso_Cp_20241019_162722.csv','impulso_Cp_20241019_163103'};
data_cp = readtable(archivos{1});
time = data_cp.t;
theta = data_cp.theta;
rlocus(-G_nodelay);
k = -0.8;
C_p = k;

L_p_pade = C_p * G_pade;

L_p_nodelay = C_p * G_nodelay;

L_p = C_p*G;
T_p = L_p/(1+L_p);

figure('Position',[300,300,800,400]); hold on;
rlocus(-G_pade);

figure('Position',[300,300,800,400]); hold on;
bode(L_p,my_bode_options);

%figure(); hold on;
%bode(L_p_nodelay, my_bode_options);
%title('Bode L_{p_{nodelay}} = C_p * G_{nodelay} con k= -1.12. Control Proporcional');
%bode(L_p_pade, my_bode_options);
%title('Bode L_{p_{pade}} = C_p * G_{pade} con k= -1.12. Control Proporcional');
%legend('Sistema 1', 'Sistema 2', 'Location', 'best');

%figure();
%bode(exp(-Td*s-Ts*s/2), my_bode_options) 
%title('Bode Retardos');


% Graficar la respuesta al impulso

% Definir el valor del impulso
valor_impulso = - 3; % El valor que quieres en t = 0

% Crear la señal de impulso
archivo_impulso_CP = 'impulso_CP_20241022_171229.csv' ;
data_impulso_CP = readtable(archivo_impulso_CP);
t = data_impulso_CP.t; 
impulso = zeros(size(t)); % Inicializar el vector con ceros
impulso(1100:1100+10) = valor_impulso; % Asignar el valor del impulso en t = 0

% Graficar la señal de impulso
figure;
stem(t, impulso, 'filled');
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Impulso Definido Personalmente');
grid on;

theta_sim_p = lsim(T_p, impulso, t);

figure('Position',[300,300,800,400]); hold on;
subplot(2,1,1)
title('Respuesta al impulso simulado');
plot(t(500:end), theta_sim_p(500:end),'LineWidth',2, 'DisplayName', ['Simulación ']);
legend;
subplot(2,1,2)
title('Respuesta al impulso medido');
plot(t(500:end), data_impulso_CP.theta(500:end), 'LineWidth',2, 'DisplayName', ['Medicion ']);
legend;



%%
close all; clc;

% Controlador proporcional integral
k_p = -0.8;
k_i = -5;
C_pi = k_p + k_i * 1/s;

L_pi = C_pi * G;
T_pi = L_pi/(1+L_pi);

% Simulacion de la respuesta de la planta con PI al escalon de referencia 5°
t = 0:0.01:10;
theta_r = 5*pi/180;
T_pi = L_pi/(1+L_pi);
r_sim = theta_r * heaviside(t);
theta_sim_p = lsim(T_pi, r_sim, t);
figure();
plot(t, theta_sim_p,'LineWidth',2, 'DisplayName', ['Simulación ']);
title('Respuesta al escalón de la planta con controlador PI');
grid on;
xlabel('t [s]');
ylabel('\theta [rad]');


% Simulación de la accion de control del PI con escalon de referencia de 5°
t = 0:0.01:20;
theta_r = 5*pi/180;
CS_pi = C_pi/(1+L_pi);
r_sim = theta_r * heaviside(t);
u_sim_pi = lsim(CS_pi, r_sim, t);
figure('Position',[300,300,800,400]); hold on;
plot(t, u_sim_pi,'LineWidth',2, 'DisplayName', ['Simulación ']);

recta = k_i*theta_r* t + theta_r*k_p;
title('Respuesta al escalón del controlador PI simulada');
grid on;
xlabel('t [s]');
ylabel('u [rad]');
k

%figure();
%bode(L_pi, my_bode_options);

%%
close all;
% Controlador proporcional derivativo
k_p = -0.4;
k_d = -0.001;
C_pd = k_p + k_d * s; 
L_pd = C_pd * G;
T_pd = L_pd /(1+L_pd);
figure(); 
bode(L_pd);

% Definir el valor del impulso
valor_impulso = - 3; % El valor que quieres en t = 0

% Crear la señal de impulso
archivo_impulso_CP = 'impulso_CPD_Tustin_20241024_194625.csv' ;
data_impulso_CP_tustin = readtable(archivo_impulso_CP);
archivo_impulso_CP = 'impulso_CPD_Tustin_20241024_194216' ;
data_impulso_CP_backwards = readtable(archivo_impulso_CP);
t_tustin = data_impulso_CP_tustin.t;  
impulso_tustin = zeros(size(t_tustin)); % Inicializar el vector con ceros
impulso_tustin(100) = valor_impulso; % Asignar el valor del impulso en t = 0
t_backwards = data_impulso_CP_backwards.t;  
impulso_backwards = zeros(size(t_backwards)); % Inicializar el vector con ceros
impulso_backwards(100) = valor_impulso; % Asignar el valor del impulso en t = 0


% Graficar la señal de impulso
%{
figure;
stem(t, impulso2, 'filled');
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Impulso Definido Personalmente');
grid on;
%}
% Simulación de la respuesta del sistema
impulso_sim = zeros(size(t_tustin)); % Inicializar el vector de impulso para la simulación
impulso_sim(100) = valor_impulso; % Asignar el valor del impulso en t = 0

% Calcular la respuesta simulada
theta_sim = lsim(T_pd, impulso_sim, t_tustin);

% Crear una única figura con tres subplots
figure('Position', [300, 300, 800, 800]);

% Graficar la respuesta simulada
subplot(3, 1, 1); % Primera subtrama (Simulación)
plot(t(1:1000), theta_sim(1:1000), 'LineWidth', 2, 'DisplayName', 'Simulación');
xlabel('Tiempo (s)');
ylabel('\theta [rad]');
title('Simulación');
legend;
grid on;

% Graficar la comparación entre simulación y medición para Backwards
subplot(3, 1, 2); % Segunda subtrama (Simulación vs Backwards)
plot(t(1:1000), data_impulso_CP_backwards.theta(682:1681), 'LineWidth', 2, 'DisplayName', 'Medición Backwards');
xlabel('Tiempo (s)');
ylabel('\theta [rad]');
title('Medición Backwards');
legend;
grid on;

% Graficar la comparación entre simulación y medición para Tustin
subplot(3, 1, 3); % Tercera subtrama (Simulación vs Tustin)
plot(t(1:1000), data_impulso_CP_tustin.theta(510:1509), 'LineWidth', 2, 'DisplayName', 'Medición Tustin');
xlabel('Tiempo (s)');
ylabel('\theta [rad]');
title('Medición Tustin');
legend;
grid on;