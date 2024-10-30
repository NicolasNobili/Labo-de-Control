clear all; close all; clc;

% Definición de la variable de Laplace
s = tf('s');

% Lista de archivos CSV que contienen las mediciones
archivos = {
    'mediciones_20241022_145537.csv', 
    'mediciones_20241022_150820.csv', 
    'mediciones_20241022_150642.csv',  
    'mediciones_20241022_145810.csv'
};

Ts = 0.01;  % Tiempo de muestreo

% Inicializar celda para almacenar los datos
Data = cell(length(archivos), 1);

% Leer los archivos CSV y almacenar los datos
for i = 1:length(archivos)
    med = readtable(archivos{i});  % Leer archivo
    Data{i} = med;                 % Guardar en celda
end

% Inicializar tiempo de establecimiento
t_s = 0;

% Calcular tiempo de establecimiento para cada archivo
for i = 1:length(archivos)
    t = Data{i}.t(103:end);        % Tiempo
    u = Data{i}.u(103:end);        % Entrada
    phi = Data{i}.phi(103:end);    % Salida

    % Tolerancia para el tiempo de establecimiento (ejemplo: 5%)
    tolerancia = 0.05;
    phi_final = phi(end);          % Valor final esperado de la salida

    % Índices donde la respuesta está dentro de la tolerancia
    indices_estable = find(abs(phi - phi_final) <= tolerancia * abs(phi_final));

    % Sumar tiempo de establecimiento
    t_s = t_s + t(indices_estable(1));
end

% Promediar tiempo de establecimiento
t_s = t_s / length(archivos);

% Calcular el polo crítico
pc = -4 / (t_s - 1.03);

% Inicializar ganancia k
k = 0;

% Calcular ganancia k a partir de los datos
for i = 1:length(archivos)
    t = Data{i}.t(103:end);        % Tiempo
    u = Data{i}.u(103:end);        % Entrada
    phi = Data{i}.phi(103:end);    % Salida
    
    % Sumar contribución a k
    k = k + phi(end) * pc^2 / u(end);
end

% Promediar k
k = k / length(archivos);

% Definir función de transferencia del servo
T_servo2 = k / (s^2 - 2 * pc * s + pc^2);
T_servo2 = k / ((s-pc)*(s-pc));

% Definir las leyendas para las gráficas
legends = {'u(t) = \pi/6 h(t-1)','u(t) = -\pi/6 h(t-1)','u(t) = -\pi/9 h(t-1) ','u(t) = \pi/9 h(t-1)'};

% Crear figura para las gráficas
figure('Position',[300,300,800,400]); hold on;
for i = 1:length(archivos)
    t = Data{i}.t(1:end);          % Tiempo
    u = Data{i}.u(1:end);          % Entrada
    phi = Data{i}.phi(1:end);      % Salida
    
    % Definir entrada simulada (escalón)
    u_sim = u(end) * heaviside(t - 1.03);
    
    % Simular la salida usando la función de transferencia
    phi_sim = lsim(T_servo2, u_sim, t);
    
    % Graficar salida simulada y medida
    plot(t(1:400), phi_sim(1:400),'LineWidth',2, 'DisplayName', ['Simulación ', num2str(i),': ',legends{i}]);
    plot(t(1:400), phi(1:400),'LineWidth',1.5, 'DisplayName', ['Medición ', num2str(i),': ',legends{i}]);
end

% Personalización de la gráfica
legend('Location','east');
grid on;
title('Respuesta al escalon: Servomotor')
xlabel('t [s]')
ylabel('\phi [rad]')

% Guardar la función de transferencia del servo
save('servo_id2', 'T_servo2');
