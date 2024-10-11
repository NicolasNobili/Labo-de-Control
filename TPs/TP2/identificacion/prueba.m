clear variables
close all
clc

s = tf('s');

% Leer el archivo CSV como una matriz (sin encabezados)
data = readtable('mediciones_20241009_130426.csv');

% Mostrar los primeros datos
time = data.t(100:end);
u = data.u(100:end);
theta = data.theta(100:end);


load('pendulo_id.mat');
load('servo_id.mat');

Ts = 0.01;
B = [0;1];
C = [1,0];
D = 0;

T_pend = tf(ss(A,B,C,D));

k = 0.8;
G = -k* T_pend * T_servo * s^2;
Gd = c2d(G,Ts);


u_sim =u(end)*heaviside(time-1);
[y_sim,t_sim] = lsim(G,u_sim,time);


figure(); hold on
plot(t_sim,y_sim)
plot(time,theta)


