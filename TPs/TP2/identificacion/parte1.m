close all
clc

% Extraemos las mediciones de simulink
%time = out.u.time;

%u = out.u.data(:); % Accion de control

%theta = out.theta.data(:); % Angulo del pendulo en deg

%theta_rad = out.theta.data(:); % Angulo del pendulo en rad

% phi = out.phi.data(:); % Angulo del servo o brazo en deg


% Regresion Lineal

%=====================
%         TO DO
%=====================


% Trasnferencia discreta

%=====================
%         TO DO
%=====================



% Polos discretos y continuos

%=====================
%         TO DO
%=====================


% Armo la forma canonica del controlador de la planta

%=====================
%         TO DO
%=====================


% Grafico las mediciones y la respuesta teorica a condiciones iniciales

%=====================
%         TO DO
%=====================


% Guardo los datos en archivo CSV:

% Datos 
datos = [u , theta,theta_rad , phi ];

% Convertir la matriz a tabla y asignar nombres a las columnas
tabla = array2table(datos, 'VariableNames', {'u', 'theta', 'theta_rad', 'phi'});

% Obtener la hora actual en formato 'HHMMSS'
hora_actual = datestr(now, 'yyyymmdd_HHMMSS');

% Crear el nombre del archivo con la hora del día
nombre_archivo = ['mediciones_' hora_actual '.csv'];

% Exportar la tabla a un archivo CSV con encabezados de columnas
writetable(tabla, nombre_archivo);

disp(['Archivo guardado como: ' nombre_archivo]);


