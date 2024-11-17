close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);


Q =[200 0 0 0;
    0 1 0 0;
    0 0 200 0;
    0 0 0 1];
R = 10;


K = -dlqr(modelo_ss_d.A, modelo_ss_d.B,Q,R);

A_des = modelo_ss_d.A+modelo_ss_d.B*K;

polos = eig(A_des)