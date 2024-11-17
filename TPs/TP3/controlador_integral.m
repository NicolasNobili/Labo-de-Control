close all; clear all; clc
Ts = 0.01;

load('planta_ss.mat')

A_monio = [modelo_ss.A,zeros(4,2);-[1 0 0 0; 0 0 1 0],zeros(2,2)];
B_monio = [modelo_ss.B;zeros(2,1)];
C_monio = [1 0 0 0 0 0; 0 0 1 0 0 0];
D_monio = 0;

planta_seguimiento_ss = ss(A_monio,B_monio,C_monio,D_monio);

planta_seguimiento_ss_d = c2d(planta_seguimiento_ss,Ts,'zoh');


A_monio_r = [modelo_ss.A,zeros(4,2);-[1 0 0 0; 0 0 1 0],zeros(2,2)];
B_monio_r = [[modelo_ss.B;zeros(2,1)],[0;0;0;0;1;1]];
C_monio_r = [1 0 0 0 0 0; 0 0 1 0 0 0];
D_monio_r = 0;

planta_seguimiento_ss_r = ss(A_monio_r,B_monio_r,C_monio_r,D_monio_r);
planta_seguimiento_ss_d_r = c2d(planta_seguimiento_ss_r,Ts,'zoh');

Q =  [1 0 0 0 0 0;
      0 1 0 0 0 0;
      0 0 1 0 0 0;
      0 0 0 1 0 0;
      0 0 0 0 100 0
      0 0 0 0 0 100];
R = 1;

K = -dlqr(planta_seguimiento_ss_d.A, planta_seguimiento_ss_d.B,Q,R);

% Sistema lazo cerrado:
polos = [0.975277581387097 + 0.0643111880052779i;0.975277581387097 - 0.0643111880052779i;0.903416385093467; 0.305673163630174; 0.6;0.600001]
A_des = planta_seguimiento_ss_d.A + planta_seguimiento_ss_d.B * K;
B_des = [0; 0; 0; 0; 1; 1];

K_des = place(A_des,B_des,polos)';



