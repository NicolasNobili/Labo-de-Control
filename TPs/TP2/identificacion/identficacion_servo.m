close all
clear variables
clc

s = tf('s');

% Leer el archivo CSV como una matriz (sin encabezados)
data = readtable('mediciones_20241006_100053.csv');

% Mostrar los primeros datos
t = data.t(100:end);
phi = data.phi(100:end)*pi/180;

b=28 * (pi/180);
a = 300 * (pi/180);
c = 1 *(pi/180);
G = a/(c*s^2+b*s+a);

u = 35*(pi/180) * heaviside(t - 1);  % Escalón en t = 1
% Simular la respuesta al escalón desplazado
[y, t_out] = lsim(G, u, t);


figure(); hold on
plot(t,phi);
plot(t,y);

save('servo_id.mat', 'a', 'b','c');