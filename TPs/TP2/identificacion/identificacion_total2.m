    clear all
close all
clc

s = tf('s');
Ts = 0.01;

archivos = {
    'mediciones_20241009_123201.csv', 
    'mediciones_20241009_123451.csv', 
    'mediciones_20241009_130309.csv',  
    'mediciones_20241009_130426.csv'
};
data = {};
% Leer los archivos CSV y almacenar los datos en la celda
for i = 1:length(archivos)     
    med = readtable(archivos{i});  % Leer el archivo actual
    data{i} = med;                  % Almacenar los datos en la celda
end



% Cargo la matriz A que representa la dinamica del pendulo
load('pendulo_id.mat');
A_pendulo= A;
B_pendulo = [0;1];
C_pendulo = [1,0];
D_pendulo = 0;

T_pend = tf(ss(A_pendulo,B_pendulo,C_pendulo,D_pendulo));

% Cargo la funcion de transferencia del servo
load('servo_id2.mat');

% Defino la transferencia G_monio que sera proporcional a la transferencia
% de la planta G: G = k*G_monio
G_monio = T_pend * T_servo2 * s^2;

% Estimo el valor de k

theta = [];
theta_sim = [];
for i=1:length(archivos)
    time = data{i}.t(100:end);
    u = data{i}.u(100:end);
    u_sim = u(end)*heaviside(time-1.00);
    y = lsim(G_monio,u_sim,time);
    theta_sim = [theta_sim ; y];
    theta = [theta;data{i}.theta(100:end)];
end


k = pinv(theta_sim)*theta;

G = k * G_monio * exp(-0.065*s);

% Armo el sistema en espacio de estados:

num_servo = T_servo2.numerator{:};
den_servo = T_servo2.denominator{:};

A = [0, 1, 0, 0;
    A_pendulo(2,1) A_pendulo(2,2) -k*den_servo(3), -k*den_servo(2);
    0, 0, 0, 1;
    0, 0, -den_servo(3), -den_servo(2)];
B = [0, k*num_servo(3) ,0 ,num_servo(3)]';
C = [1, 0, 0, 0];
D = [0];

planta_ss = ss(A,B,C,D);
G_ss = tf(planta_ss);

% Grficos
i = 2;  
time = data{i}.t(1:end);
u = data{i}.u(1:end);
theta = data{i}.theta(1:end);

u_sim =u(end)*heaviside(time-1.0);
[theta_sim,t_sim] = lsim(G,u_sim,time);

figure('Position',[300,300,800,400]); hold on
plot(t_sim,theta_sim,'DisplayName','Simulacion: u(t) = \pi/6 h(t-1)')
plot(time,theta,'DisplayName','Medicion: u(t) = \pi/6 h(t-1)')

legend;
grid on
xlabel('t [s]')
ylabel('\theta [rad]')




