close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);
%% 
% Sistema en espacio de estados con estado aumentado:
% Agrego como entradas las referencias para que se discretice su matriz al
% al pasarla por c2d()
A_monio_r = [modelo_ss.A,zeros(4,2);-[1 0 0 0; 0 0 1 0],zeros(2,2)];
B_monio_r = [[modelo_ss.B;zeros(2,1)],[0 0;0 0;0 0;0 0;1 0;0 1]];
C_monio_r = [1 0 0 0 0 0; 0 0 1 0 0 0];
D_monio_r = 0;

planta_seguimiento_ss_r = ss(A_monio_r,B_monio_r,C_monio_r,D_monio_r);
planta_seguimiento_ss_r_d = c2d(planta_seguimiento_ss_r,Ts,'zoh');

plc_c = [ -5 - 7.8646i ; -5 + 7.8646i ; -10+2i; -10-2i ; -80];

plc_d = exp(plc_c * 0.01);
%{
K  = -place(planta_seguimiento_ss_r_d.A , planta_seguimiento_ss_r_d.B(:,1) , plc_d);

% Sistema lazo cerrado:
A_des = planta_seguimiento_ss_r_d.A + planta_seguimiento_ss_r_d.B(:,1) * K;
B_des = planta_seguimiento_ss_r_d.B(:,2:3); % Solo la parte de la referencia, con la entrada posta se realimenta.
C_des = planta_seguimiento_ss_r_d.C;
%}
% El problema de querer agregar accion integral para ambas salidas es que
% las matrices A y B del sistema con estado aumentado no forman un par
% controlable. Algo parecido pasaba al calcular la matriz de feedforward,
% donde el factor que multiplica a theta_ref tiende a infinito. 

% Probamos poniendo accion integral unicamente en phi...


%% Es lo mismo que arriba pero no hay accion integral en theta
close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')

A_monio_r = [modelo_ss.A,zeros(4,1);-[0 0 1 0],zeros(1,1)];
B_monio_r = [[modelo_ss.B;zeros(1,1)],[0;0;0;0;1]];
C_monio_r = [1 0 0 0 0; 0 0 1 0 0];
D_monio_r = 0;

planta_ss_r = ss(A_monio_r,B_monio_r,C_monio_r,D_monio_r);
planta_ss_r_d = c2d(planta_ss_r,Ts,'zoh');

plc_c = [-5 - 7.8646i ; -5 + 7.8646i ; -10+2i; -10-2i  ; -7];

plc_d = exp(plc_c * 0.01);

K  = -place(planta_ss_r_d.A , planta_ss_r_d.B(:,1) , plc_d);

% Sistema lazo cerrado:
A_des = planta_ss_r_d.A + planta_ss_r_d.B(:,1) * K;
B_des = planta_ss_r_d.B(:,2);
C_des = planta_ss_r_d.C;

ss_lc_integral = ss(A_des,B_des,C_des,0,Ts);

% Simulo respuesta al escalon para phi. r_phi corresponde a la segunda
% entrada.

% Parámetros
T_total = 16; % Duración total de la simulación en segundos
t = 0:Ts:T_total-Ts; % Vector de tiempo

% Secuencia de escalones para r_phi
r_phi = zeros(size(t));

% Escalones para la segunda entrada
r_phi(t >= 0 & t < 1) = 0;
r_phi(t >= 1 & t < 5) = pi * 30 / 180;
r_phi(t >= 5 & t < 9) = 0;
r_phi(t >= 9 & t < 13) = -pi * 20 / 180;
r_phi(t >= 13 & t <= 17) = 0;


% Simulación del sistema
[Y, T_sim, X]  = lsim(ss_lc_integral,r_phi,t);


% THETA
figure('Position',[300,300,800,500]); hold on;
subplot(2,1,1); hold on
title('Respuesta $\theta$ : Simulacion', 'Interpreter', 'latex')
plot(t, X(:,1),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\theta$(rad)','Interpreter','Latex');

subplot(2,1,2); hold on
title('Respuesta $\theta$ : Observador', 'Interpreter', 'latex')
% AGREGAR MEDICION
xlabel('t(s)');
ylabel('$\theta$(rad)','Interpreter','Latex');

% THETA_P
figure('Position',[300,300,800,500]); hold on;
subplot(2,1,1); hold on
title('Respuesta $\dot{\theta}$ : Simulacion', 'Interpreter', 'latex')
plot(t, X(:,2),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\dot{\theta}$(rad/s)','Interpreter','Latex');

subplot(2,1,2); hold on
title('Respuesta $\dot{\theta}$ : Observador', 'Interpreter', 'latex')
% AGREGAR MEDICION
xlabel('t(s)');
ylabel('$\dot{\theta}$(rad/s)','Interpreter','Latex');

% PHI
figure('Position',[300,300,800,400]); hold on;
subplot(2,1,1); hold on
title('Respuesta $\phi$ : Simulacion', 'Interpreter', 'latex')
plot(t, X(:,3),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\phi$(rad)','Interpreter','Latex');

subplot(2,1,2); hold on
title('Respuesta $\phi$ : Observador', 'Interpreter', 'latex')
% AGREGAR MEDICION
xlabel('t(s)');
ylabel('$\phi$(rad)','Interpreter','Latex');

% PHI_P
figure('Position',[300,300,800,500]); hold on;
subplot(2,1,1); hold on
title('Respuesta $\dot{\phi}$ : Simulacion', 'Interpreter', 'latex')
plot(t, X(:,4),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\dot{\phi}$(rad/s)','Interpreter','Latex');

subplot(2,1,2); hold on
title('Respuesta $\dot{\phi}$ : Observador', 'Interpreter', 'latex')
% AGREGAR MEDICION
xlabel('t(s)');
ylabel('$\dot{\phi}$(rad/s)','Interpreter','Latex');








