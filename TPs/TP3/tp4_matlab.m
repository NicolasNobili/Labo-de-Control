close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);

% OBSERVADOR:

pp_c = pole(modelo_ss);
pp_d = exp(pp_c*0.01);

%po_d = [0.3, 0.5, 0.5, 0.35];
po_d = [0.4, 0.35, 0.4, 0.35];
po_c = real(pp_c) * 10;

L = place(modelo_ss_d.A',modelo_ss_d.C',po_d)';


% CONTROLADOR 
Q =[200 0 0 0;
    0 1 0 0;
    0 0 200 0;
    0 0 0 1];
R = 10;


K = -dlqr(modelo_ss_d.A, modelo_ss_d.B,Q,R);

A_des = modelo_ss_d.A+modelo_ss_d.B*K;

polos = eig(A_des);

% PRECOMPENSACION

A = modelo_ss_d.A;
B = modelo_ss_d.B;
C = modelo_ss_d.C;

F = (C * (eye(4) -(A + B * K))^(-1) * B);

f2 = 1/F(2);