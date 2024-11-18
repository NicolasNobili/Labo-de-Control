close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);

pp_c = pole(modelo_ss);
pp_d = exp(pp_c*0.01);

po_d = [0.45, 0.4, 0.35, 0.30];

po_c = log(po_d)/0.01;

L = place(modelo_ss_d.A',modelo_ss_d.C',po_d)'

%%

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
