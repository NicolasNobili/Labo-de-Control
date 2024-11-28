close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);
%%
%===============================================
%
%                 OBSERVADOR
%
%===============================================

% Planteo los polos del observador en tiempo discreto y calculo L
% utlizadndo place()
%po_d = [0.45, 0.4, 0.35, 0.30];
%po_d = [0.6 , 0.6 , 0.8 , 0.8];

po_c = [-30 -30 -10 -10];
po_d = exp(0.01 * po_c);
%po_d = [0.7 , 0.7 , 0.5 , 0.5];

% Calculo los polos continuos equivalentes teniendo en cuenta que se
% utilizo zoh para la discretizacion.
%po_c = log(po_d)/0.01;

% Calculo de L
L = place(modelo_ss_d.A',modelo_ss_d.C',po_d)';

% Se implemento el observador en la planta real y se observo como responde
% ante una secuuencia de escalones en la entrada u. Luego se graficaron los
% resultados obtenidos comparando la observacion con las mediciones de los
% sensores.
data = readtable('test_observador_20241126_182028');
figure(); 

subplot(4,1,1); hold on
plot(data.t, data.theta)
plot(data.t, data.theta_sim)
legend('$\theta$ real', '$\theta$ estimado', 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 12) % Leyenda con fuente más grande

subplot(4,1,2); hold on
plot(data.t, data.theta_p)
plot(data.t, data.theta_p_sim)
legend('$\dot{\theta}$ real', '$\dot{\theta}$ estimado', 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 12) % Leyenda con fuente más grande

subplot(4,1,3); hold on
plot(data.t, data.phi)
plot(data.t, data.phi_sim)
legend('$\phi$ real', '$\phi$ estimado', 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 12) % Leyenda con fuente más grande

subplot(4,1,4); hold on
plot(data.t, data.phi_p)
plot(data.t, data.phi_p_sim)
legend('$\dot{\phi}$ diferencias finitas', '$\dot{\phi}$ estimado', 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 12) % Leyenda con fuente más grande

%%
%===============================================
%
%                 CONTROLADOR
%
%===============================================

% Se plantean los polos deseados del sistema a lazo cerrado 
plc_c = [ -5 - 7.8646i ; -5 + 7.8646i ; -10+2i; -10-2i ];
%plc_c = [-5 - 5i ; -5 + 5i ; -6; -6.00000001];

% Se calculan los polos discretos equivalentes ('zoh') y luego se calcula
% la matriz de realimentacion de estados utilizando place
plc_d = exp(plc_c * 0.01);
K  = -place(modelo_ss_d.A , modelo_ss_d.B , plc_d);
A_des = modelo_ss_d.A+modelo_ss_d.B*K;
%%
% Simulo la respuesta al impulso del sistema
ss_impulso = ss(A_des,modelo_ss_d.B,modelo_ss_d.C,0,Ts); 

% Leer archivo de impulso
archivo_impulso_C = 'impulso_controlador_20241126_175728.csv' ;
data_impulso_C = readtable(archivo_impulso_C);
t = data_impulso_C.t; 



% Simulo la respuesta al impulso utilizando initial() dando una condicion inicial
% no nula a la velocidad angular del pendulo y grafico los resultados para 
% cada variable de estado junto con las mediciones.
t_0 = 1.95;
n_pad = round(t_0/Ts);
[Y, T_sim, X] = initial(ss_impulso, [0 4 0 0], t(end - n_pad));
X1 = [zeros(n_pad,1);X(:,1)];  
X2 = [zeros(n_pad,1);X(:,2)];
X3 = [zeros(n_pad,1);X(:,3)];
X4 = [zeros(n_pad,1);X(:,4)];



figure('Position',[300,300,800,400]); hold on;
% THETA
subplot(2,2,1); hold on
title('Respuesta Impulso: $\theta$', 'Interpreter', 'latex')
plot(t, X1,'LineWidth', 2)
plot(t, data_impulso_C.theta_sim,'LineWidth', 2,'Color', [1, 0.5, 0])
xlabel('t(s)');
ylabel('$\theta$(rad)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');


% THETA_P
subplot(2,2,3); hold on
title('Respuesta Impulso: $\dot{\theta}$', 'Interpreter', 'latex')
plot(t, X2,'LineWidth', 2)
plot(t, data_impulso_C.theta_p_sim,'LineWidth', 2,'Color', [1, 0.5, 0])
xlabel('t(s)');
ylabel('$\dot{\theta}$(rad/s)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');


% PHI
subplot(2,2,2); hold on
title('Respuesta Impulso: $\phi$', 'Interpreter', 'latex')
plot(t, X3,'LineWidth', 2)
plot(t, data_impulso_C.phi_sim,'LineWidth', 2,'Color', [1, 0.5, 0])
xlabel('t(s)');
ylabel('$\phi$(rad)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');


% PHI_P
subplot(2,2,4); hold on
title('Respuesta Impulso: $\dot{\phi}$', 'Interpreter', 'latex')
plot(t, X4,'LineWidth', 2)
plot(t, data_impulso_C.phi_p,'LineWidth', 2,'Color', [1, 0.5, 0])
xlabel('t(s)');
ylabel('$\dot{\phi}$(rad/s)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');



%%
%===============================================
%
%                PRECOMPENSACION
%
%===============================================
% Calculo la matriz F de precompensacion:
A = modelo_ss_d.A;
B = modelo_ss_d.B;
C = modelo_ss_d.C;
F = (C * (eye(4) -(A + B * K))^(-1) * B);

f2 = 1/F(2);
A_des = modelo_ss_d.A+modelo_ss_d.B*K;
ss_precomp = ss(A_des,modelo_ss_d.B * (1/F),modelo_ss_d.C,0,Ts); 

% Simulo respuesta al escalon para phi. r_phi corresponde a la segunda
% entrada.

% Mediciones
archivo_test= 'test_controlador_precomp_20241126_181149.csv' ;
data = readtable(archivo_test);

% Parámetros
T_total = 20; % Duración total de la simulación en segundos
t = data.t(1:1:T_total/Ts); % Vector de tiempo
% Secuencia de escalones para r_phi
r_phi =  data.r_phi(1:T_total/Ts);
r_theta = zeros(size(t));

% Crear la señal de entrada combinada
R = [r_theta, r_phi(1:T_total/Ts)]';

% Simulación del sistema
[Y, T_sim, X]  = lsim(ss_precomp, R, t);


figure('Position',[300,300,800,500]); hold on;
% THETA
subplot(2,2,1); hold on
title('Respuesta: $\theta$', 'Interpreter', 'latex')
plot(t, X(:,1),'LineWidth', 2)
plot(t,data.theta_sim(1:T_total/Ts),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\theta$(rad)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');

% THETA_P
subplot(2,2,3); hold on
title('Respuesta: $\dot{\theta}$', 'Interpreter', 'latex')
plot(t, X(:,2),'LineWidth', 2)
plot(t,data.theta_p_sim(1:T_total/Ts),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\dot{\theta}$(rad/s)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');


% PHI
subplot(2,2,2); hold on
title('Respuesta: $\phi$', 'Interpreter', 'latex')
plot(t, X(:,3),'LineWidth', 2)
plot(t,data.phi_sim(1:T_total/Ts),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\phi$(rad)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');


% PHI_P
subplot(2,2,4); hold on
title('Respuesta: $\dot{\phi}$', 'Interpreter', 'latex')
plot(t,X(:,4),'LineWidth', 2)
plot(t,data.phi_p(1:T_total/Ts),'LineWidth', 2)
xlabel('t(s)');
ylabel('$\dot{\phi}$(rad/s)','Interpreter','Latex');
grid on;
legend('Simulación', 'Observador', 'Location', 'best');


