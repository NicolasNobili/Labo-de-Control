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
B_monio_r = [[modelo_ss.B;zeros(2,1)],[0 0;0 0;0 0;0 0;1 0;0 1]];
C_monio_r = [1 0 0 0 0 0; 0 0 1 0 0 0];
D_monio_r = 0;

planta_seguimiento_ss_r = ss(A_monio_r,B_monio_r,C_monio_r,D_monio_r);
planta_seguimiento_ss_r_d = c2d(planta_seguimiento_ss_r,Ts,'zoh');

plc_c = [ -5 - 7.8646i ; -5 + 7.8646i ; -10+2i; -10-2i ; -80 ; -100];

plc_d = exp(plc_c * 0.01);

K  = -place(planta_seguimiento_ss_r_d.A , planta_seguimiento_ss_r_d.B(:,1) , plc_d);

% Sistema lazo cerrado:
A_des = planta_seguimiento_ss_r_d.A + planta_seguimiento_ss_r_d.B(:,1) * K;
B_des = planta_seguimiento_ss_r_d.B(:,2:3);
C_des = planta_seguimiento_ss_r_d.C;

%%
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
B_monio_r = [[modelo_ss.B;zeros(2,1)],[0 0;0 0;0 0;0 0;1 0;0 1]];
C_monio_r = [1 0 0 0 0 0; 0 0 1 0 0 0];
D_monio_r = 0;

planta_seguimiento_ss_r = ss(A_monio_r,B_monio_r,C_monio_r,D_monio_r);
planta_seguimiento_ss_r_d = c2d(planta_seguimiento_ss_r,Ts,'zoh');

plc_c = [ -5 - 7.8646i ; -5 + 7.8646i ; -10+2i; -10-2i ; -80 ; -100];

plc_d = exp(plc_c * 0.01);

K  = -place(planta_seguimiento_ss_r_d.A , planta_seguimiento_ss_r_d.B(:,1) , plc_d);

% Sistema lazo cerrado:
A_des = planta_seguimiento_ss_r_d.A + planta_seguimiento_ss_r_d.B(:,1) * K;
B_des = planta_seguimiento_ss_r_d.B(:,2:3);
C_des = planta_seguimiento_ss_r_d.C;







