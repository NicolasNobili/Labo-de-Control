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
% Controlador proporcional

archivos = {'impulso_Cp_20241019_162722.csv','impulso_Cp_20241019_163103'};
data_cp = readtable(archivos{1});
time = data_cp.t;
theta = data_cp.theta;

k = -0.8;
C_p = k;
L_p = C_p * G_pade;
T_p = L_p/(1+L_p);

figure();
bode(L_p, my_bode_options);
title('Bode L_p = C_p * G con k= -0.8. Control Proporcional');

figure(); hold on
theta_sim = impulse(T_p,time);
plot(time,theta_sim,'LineWidth',1.5,'DisplayName','Simulacion Impulso');
plot(time,theta,'LineWidth',1.5,'DisplayName','Medicion Impulso');
title('Respuesta al impulso de T_p con k= -0.8. Control Proporcional');

%%
% Controlador proporcional derivativo
k_p = -0.8;
k_d = -0.1;
C_pd = k_p + k_d * s;
C_pd = -db2mag(-19)*(s+8);
L_pd = C_pd * G_pade;
figure(); hold on
bode(L_pd);


% Tustin
C_pd_tustin = c2d(C_pd, Ts,'tustin');

