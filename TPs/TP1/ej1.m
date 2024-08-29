close all
clear all
clc

% Config:
s = tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

%Constantes:
g = 9.8;

a_max = 0.4;
h_max = 0.9;
b = 0.1;
d = 0.01065;
Q_i = 8e-3/60;

m = (a_max - b)/h_max;

% Equilibrio
x_e = 0.45;
u_e = Q_i/(pi * d^2 * sqrt(2*g*x_e)/4);

orden = 1;
x=sym('x',[orden 1],'real');
u=sym('u','real');


f = (Q_i - pi * d^2 * sqrt(2*g*x)*u/4 )/(m^2 * x^2 + 2*b*m*x + b^2);
g = x;

A = jacobian(f,x);
A = double(subs(A,{x,u},{x_e,u_e}));

B = jacobian(f,u);
B = double(subs(B,{x,u},{x_e,u_e}));

C = jacobian(g,x);
C = double(subs(C,{x,u},{x_e,u_e}));

D = jacobian(g,u);
D = double(subs(D,{x,u},{x_e,u_e}));

% Trasnferencia de la Planta Linealizada
P = tf(ss(A,B,C,D));

%%




%%
