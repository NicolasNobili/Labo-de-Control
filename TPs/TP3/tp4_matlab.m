close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);

% OBSERVADOR:

pp_c = pole(modelo_ss);
pp_d = exp(pp_c*0.01);

po_d = [0.45, 0.4, 0.35, 0.30];

po_c = log(po_d)/0.01;

L = place(modelo_ss_d.A',modelo_ss_d.C',po_d)';

data = readtable('prueba_observador20241117_160224');
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



% CONTROLADOR:
plc_c = [ -5 - 7.8646i ; -5 + 7.8646i ; -10+2i; -10-2i ];

plc_d = exp(plc_c * 0.01);

K  = -place(modelo_ss_d.A , modelo_ss_d.B , plc_d);

% Simulo la respuesta al impulso del sistema
A_des = modelo_ss_d.A+modelo_ss_d.B*K;

ss_impulso = ss(A_des,modelo_ss_d.B,[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1],0,0.01); 
% Crear la señal de impulso
valor_impulso = -0.85
archivo_impulso_C = 'impulso_controlador20241117_235500.csv' ;
data_impulso_C = readtable(archivo_impulso_C);
t = data_impulso_C.t; 
impulso = zeros(size(t)); % Inicializar el vector con ceros
impulso(125:125+10) = valor_impulso; % Asignar el valor del impulso en t = 0

% Graficar la señal de impulso
figure;
stem(t, impulso, 'filled');
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Impulso Definido Personalmente');
grid on;


imp_sim = lsim(ss_impulso, impulso, t);

close all
figure('Position',[300,300,800,400]); hold on;
subplot(2,2,1); hold on
title('Respuesta Impulso $\theta$ : Simulacion', 'Interpreter', 'latex')
plot(t, imp_sim(:,1),'LineWidth', 2)
subplot(2,2,3); hold on
title('Respuesta Impulso $\theta$ : Observador', 'Interpreter', 'latex')
plot(t, data_impulso_C.theta_sim,'LineWidth', 2,'Color', [1, 0.5, 0])

%figure('Position',[300,300,800,400]); hold on;
subplot(2,2,2); hold on
title('Respuesta Impulso $\dot{\theta}$ : Simulacion', 'Interpreter', 'latex')
plot(t, imp_sim(:,2),'LineWidth', 2)
subplot(2,2,4); hold on
title('Respuesta Impulso $\dot{\theta}$ : Observador', 'Interpreter', 'latex')
plot(t, data_impulso_C.theta_p_sim,'LineWidth', 2,'Color', [1, 0.5, 0])

figure('Position',[300,300,800,400]); hold on;
subplot(2,2,1); hold on
title('Respuesta Impulso $\phi$ : Simulacion', 'Interpreter', 'latex')
plot(t, imp_sim(:,3),'LineWidth', 2)
subplot(2,2,3); hold on
title('Respuesta Impulso $\phi$ : Observador', 'Interpreter', 'latex')
plot(t, data_impulso_C.phi_sim,'LineWidth', 2,'Color', [1, 0.5, 0])

%figure('Position',[300,300,800,400]); hold on;
subplot(2,2,2); hold on
title('Respuesta Impulso $\dot{\phi}$ : Simulacion', 'Interpreter', 'latex')
plot(t, imp_sim(:,4),'LineWidth', 2)
subplot(2,2,4); hold on
title('Respuesta Impulso $\dot{\phi}$ : Observador', 'Interpreter', 'latex')
plot(t, data_impulso_C.phi_p,'LineWidth', 2,'Color', [1, 0.5, 0])




% PRECOMPENSACION

A = modelo_ss_d.A;
B = modelo_ss_d.B;
C = modelo_ss_d.C;

F = (C * (eye(4) -(A + B * K))^(-1) * B);

f2 = 1/F(2);