close all
clear variables
clc

% Config:
s = tf('s');

% Bode options
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

%Constantes:
G = 9.8; % gravedad  [m/s^2]
a_max = 0.4; % lado base mayor maximo [m]
h_max = 0.9; % altura maxima [m]
h_e = 0.45; % altura de equilibrio [m]
b = 0.1; % lado base menor [m]
d = 0.01065; % diametro de la valvula [m]
Q_i = 8e-3/60; % flujo de entrada []

m = (a_max - b)/h_max;


% Punto de trabajo
x_e = 0.45;
u_e = Q_i/(pi * d^2 * sqrt(2*G*x_e)/4);

% Definicion de las variables simbolicas
orden = 1;
x=sym('x',[orden 1],'real');
u=sym('u','real');


% Funcion de estado
f = (Q_i - pi * d^2 * sqrt(2*G*x)*u/4 )/(m^2 * x^2 + 2*b*m*x + b^2);

% Funcion de salida
g = x;

% Linealizacion 
As = jacobian(f,x);
Bs = jacobian(f,u);
Cs = jacobian(g,x);
Ds = jacobian(g,u);

% Se reemplaza con los valores de trabajo en las matrices simbolicas
A = double(subs(As,{x,u},{x_e,u_e}));
B = double(subs(Bs,{x,u},{x_e,u_e}));
C = double(subs(Cs,{x,u},{x_e,u_e}));
D = double(subs(Ds,{x,u},{x_e,u_e}));

% Trasnferencia de la Planta Linealizada
Ps = tf(ss(A,B,C,D));


% Controlador disenado
k= db2mag(-0.26+8);
C_monio = k*(s+0.00237);
C = -C_monio/s;

ts = 1;
pd = 0.00237;
kd = -2.4378;

% Forward Euler
cd_fe = tf([kd, -kd+kd*pd*ts],[1,-1],ts);

% Backward Euler
cd_be = tf([kd*(1+pd*ts),-kd],[1,-1],ts);

% Tustin
cd_t = c2d(C,ts,'tustin');


