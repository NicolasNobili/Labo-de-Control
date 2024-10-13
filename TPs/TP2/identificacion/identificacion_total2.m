clear all
close all
clc

s = tf('s');
Ts = 0.01;

% Leer el archivo CSV como una matriz (sin encabezados)
data = readtable('mediciones_20241009_123201.csv');

% Mostrar los primeros datos
time = data.t(100:end);
u = data.u(100:end);
theta = data.theta(100:end);

% Cargo la matriz A que representa la dinamica del pendulo
load('pendulo_id.mat');
A_pendulo= A;
B_pendulo = [0;1];
C_pendulo = [1,0];
D_pendulo = 0;

T_pend = tf(ss(A_pendulo,B_pendulo,C_pendulo,D_pendulo));

% Cargo la funcion de transferencia del servo
load('servo_id.mat');

% Defino la transferencia G_monio que sera proporcional a la transferencia
% de la planta G: G = k*G_monio
G_monio = T_pend * T_servo * s^2;

% Estimo el valor de k
u_sim =u(end)*heaviside(time-1);
theta_sim = lsim(G_monio,u_sim,time);A

k = pinv(theta_sim)*theta;

G = k * G_monio;
[theta_sim,t_sim] = lsim(G,u_sim,time);

figure(); hold on
plot(t_sim,theta_sim,'DisplayName','Simulacion')
plot(time,theta,'DisplayName','Medicion')
legend;



% Armo el sistema en espacio de estados:

num_servo = T_servo.numerator{:};
den_servo = T_servo.denominator{:};

A = [0, 1, 0, 0;
    A_pendulo(2,1) A_pendulo(2,2) -k*den_servo(3), -k*den_servo(2);
    0, 0, 0, 1;
    0, 0, -den_servo(3), -den_servo(2)];
B = [0, k*num_servo(3) ,0 ,num_servo(3)]';
C = [1, 0, 0, 0];
D = [0];

planta_ss = ss(A,B,C,D);
G_ss = tf(planta_ss);

[theta_sim,t_sim] = lsim(G_ss,u_sim,time);

figure(); hold on
plot(t_sim,theta_sim,'DisplayName','Simulacion')
plot(time,theta,'DisplayName','Medicion')
legend;





