close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);

pp_c = pole(modelo_ss);
pp_d = exp(pp_c*0.01);

po_d = [0.3, 0.5, 0.5, 0.35];
po_c = real(pp_c) * 10;

L = place(modelo_ss_d.A',modelo_ss_d.C',po_d)';
