close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);


Q =[20 0 0 0;
    0 1 0 0;
    0 0 20 0;
    0 0 0 1];
R = 1;


K = -dlqr(modelo_ss_d.A, modelo_ss_d.B,Q,R)
%K = [2.7998,-0.1750,-1.7505,-0.4214];

A = modelo_ss_d.A;
B = modelo_ss_d.B;
C = modelo_ss_d.C;

F = (C * (eye(4) -(A + B * K))^(-1) * B);

f2 = 1/F(2)