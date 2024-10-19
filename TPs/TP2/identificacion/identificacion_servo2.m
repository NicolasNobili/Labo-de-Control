close all;            % Cerrar todas las figuras abiertas
clear variables;     % Limpiar las variables del espacio de trabajo
clc;                 % Limpiar la consola

% Definición de la variable de Laplace
s = tf('s');

% Lista de archivos CSV que contienen las mediciones
archivos = {
    'mediciones_20241009_123201.csv', 
    'mediciones_20241009_123451.csv', 
    'mediciones_20241009_130309.csv',  
    'mediciones_20241009_130426.csv'
};

Ts = 0.01;  % Tiempo de muestreo, asumido constante entre experimentos

% Inicializar una celda para almacenar los datos
Data = cell(length(archivos), 1);

% Leer los archivos CSV y almacenar los datos en la celda
for i = 1:length(archivos)     
    med = readtable(archivos{i});  % Leer el archivo actual
    Data{i} = med;                  % Almacenar los datos en la celda
end

% Inicializar la variable para el tiempo de establecimiento
t_s = 0;

% Calcular el tiempo de establecimiento para cada archivo
for i = 1:length(archivos)
    % Extraer las columnas relevantes del archivo
    t = Data{i}.t(103:end);          % Tiempo
    u = Data{i}.u(103:end);          % Entrada
    phi = Data{i}.phi(103:end);      % Salida

    % Tolerancia para tiempo de establecimiento (ejemplo: 2%)
    tolerancia = 0.05;

    % Valor final esperado
    phi_final = phi(end);            % Último valor de salida como valor final esperado

    % Índices donde la respuesta se encuentra dentro del margen de tolerancia
    indices_estable = find(abs(phi - phi_final) <= tolerancia * abs(phi_final));

    % Determinar el tiempo de establecimiento
    % Se utiliza el primer índice estable para calcular el tiempo de establecimiento
    t_s = t_s + t(indices_estable(1));
end

% Promediar el tiempo de establecimiento
t_s = t_s / length(archivos);

% Calcular el polo crítico
pc = -4 / (t_s - 1.03);

% Inicializar la variable k
k = 0;

% Calcular la ganancia k utilizando los datos de cada archivo
for i = 1:length(archivos)     
    t = Data{i}.t(103:end);          % Tiempo
    u = Data{i}.u(103:end);          % Entrada
    phi = Data{i}.phi(103:end);      % Salida
    
    % Sumar la contribución de cada medición a k
    k = k + phi(end) * pc^2 / u(end);
end

% Promediar k
k = k / length(archivos);

% Definir la función de transferencia del servo
T_servo2 = k / (s^2 - 2 * pc * s + pc^2);

% Graficar la respuesta del sistema

legends = {'u(t) = \pi/6 h(t-1)','u(t) = -\pi/6 h(t-1)','u(t) = -\pi/9 h(t-1) ','u(t) = \pi/9 h(t-1) '}

figure('Position',[300,300,800,400]); hold on;
for i = 1:length(archivos)     
    t = Data{i}.t(1:end);          % Tiempo
    u = Data{i}.u(1:end);          % Entrada
    phi = Data{i}.phi(1:end);      % Salida
    
    % Definir la entrada simulada como un escalón
    u_sim = u(end) * heaviside(t - 1.03);
    
    % Simular la salida usando la función de transferencia
    phi_sim = lsim(T_servo2, u_sim, t);
    
    % Graficar la salida simulada y la medida
    plot(t(1:400), phi_sim(1:400),'LineWidth',2, 'DisplayName', ['Simulación ', num2str(i),': ',legends{i}]);
    plot(t(1:400), phi(1:400),'LineWidth',1.5, 'DisplayName', ['Medición ', num2str(i),': ',legends{i}]);
end
legend('Location','east');
grid on;
title('Respuesta al escalon: Servomotor')
xlabel('t [s]')
ylabel('\phi [rad]')
% Guardar la función de transferencia del servo
save('servo_id2', 'T_servo2');
