close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);


plc_c = [ -5 - 7.8646i ; -5 + 7.8646i ; -10+2i; -10-2i ];

plc_d = exp(plc_c * 0.01);

K  = -place(modelo_ss_d.A , modelo_ss_d.B , plc_d);

A = modelo_ss_d.A;
B = modelo_ss_d.B;
C = modelo_ss_d.C;

F = (C * (eye(4) -(A + B * K))^(-1) * B);

f2 = 1/F(2)