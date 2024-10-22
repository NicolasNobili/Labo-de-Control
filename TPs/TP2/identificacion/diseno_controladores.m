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
k = -0.4;
C_p = k;
L_p_pade = C_p * G_pade;
L_p_nodelay = C_p * G_nodelay;

figure(); hold on;
bode(L_p_nodelay, my_bode_options);
title('Bode L_{p_{nodelay}} = C_p * G_{nodelay} con k= -1.12. Control Proporcional');
bode(L_p_pade, my_bode_options);
title('Bode L_{p_{pade}} = C_p * G_{pade} con k= -1.12. Control Proporcional');
legend('Sistema 1', 'Sistema 2', 'Location', 'best');

figure();
bode(exp(-Td*s-Ts*s/2), my_bode_options) 
title('Bode Retardos');

L_p = C_p*G;
T_p = L_p/(1+L_p);
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
plot(t(500:end), theta_sim_p(500:end),'LineWidth',2, 'DisplayName', ['Simulación ']);
legend;
subplot(2,1,2)
plot(t(500:end), data_impulso_CP.theta(500:end), 'LineWidth',2, 'DisplayName', ['Medicion ']);
title('Respuesta al impulso simulado y medido');
legend;


%%
figure(); hold on
theta_sim = impulse(T_p,time);
plot(time,theta_sim,'LineWidth',1.5,'DisplayName','Simulacion Impulso');
plot(time,theta,'LineWidth',1.5,'DisplayName','Medicion Impulso');
title('Respuesta al impulso de T_p con k= -0.8. Control Proporcional');

%%
close all; clc;

% Controlador proporcional integral

k_p = -0.8;
k_i = -5;
C_pi = k_p + k_i * 1/s;

L_pi = C_pi * G_pade;
T_pi = L_pi/(1+L_pi);
% Simular la salida usando la función de transferencia
t = 0:0.01:10;
theta_r = 5*pi/180;
CS = C_pi/(1+L_pi);
% Definir entrada simulada (escalón)
r_sim = theta_r * heaviside(t);
u_sim_pi = lsim(CS, r_sim, t);

figure();
bode(L_pi, my_bode_options);

figure('Position',[300,300,800,400]); hold on;
plot(t, u_sim_pi,'LineWidth',2, 'DisplayName', ['Simulación ']);

% Para comparar con el proporcional
t = 0:0.01:10;
theta_r = 5*pi/180;
CS = C_p/(1+L_p);
% Definir entrada simulada (escalón)
r_sim = theta_r * heaviside(t);
u_sim_p = lsim(CS, r_sim, t);

figure();
plot(t, u_sim_p,'LineWidth',2, 'DisplayName', ['Simulación ']);
title('Respuesta al escalon simulada');


%%
% Controlador proporcional derivativo
k_p = -0.8;
k_d = -0.1;
C_pd = k_p + k_d * s;
C_pd = -0.6*(s/8+1);
L_pd = C_pd * G_pade;
figure(); hold on
bode(C_pd*G_pade);

