close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')
modelo_ss.C = [1 0 0 0; 0 0 1 0];
modelo_ss_d = c2d(modelo_ss,Ts);

pp_c = pole(modelo_ss);

po_c = pp_c * 10;
po_d = exp(po_c*0.01);

po_d(4) = po_d(3) + 0.000001; 

L = place(modelo_ss_d.A',modelo_ss_d.C',po_d)';
