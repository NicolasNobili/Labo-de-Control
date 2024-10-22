close all
clc

% Extraemos las mediciones de simulink
%time = out.u.time;

t = out.tout(:); 

u = out.u(:); % Accion de control

theta = out.theta(:); % Angulo del pendulo en deg

phi = out.phi(:); % Angulo del servo o brazo en deg


% Guardo los datos en archivo CSV:

% Datos 
datos = [t, u , theta , phi ];

% Convertir la matriz a tabla y asignar nombres a las columnas
tabla = array2table(datos, 'VariableNames', {'t','u', 'theta', 'phi'});

% Obtener la hora actual en formato 'HHMMSS'
hora_actual = datestr(now, 'yyyymmdd_HHMMSS');

% Crear el nombre del archivo con la hora del día
nombre_archivo = ['impulso_CP_' hora_actual '.csv'];

% Exportar la tabla a un archivo CSV con encabezados de columnas
writetable(tabla, nombre_archivo);

disp(['Archivo guardado como: ' nombre_archivo]);


