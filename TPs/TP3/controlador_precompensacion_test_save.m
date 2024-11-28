close all
clc

% Extraemos las mediciones de simulink
%time = out.u.time;

t = out.tout(:); 

theta = out.theta(1,1,:); % Angulo del pendulo en rad
theta = theta(:);
theta_sim = out.theta(2,1,:); % Angulo del pendulo en rad
theta_sim = theta_sim(:);

theta_p = out.theta_p(1,1,:); %Velocidad angular del pendulo en rad/s
theta_p = theta_p(:);
theta_p_sim = out.theta_p(2,1,:); %Velocidad angular del pendulo en rad/s
theta_p_sim = theta_p_sim(:);

phi = out.phi(1,1,:); % Angulo del servo o brazo en rad
phi = phi(:);
phi_sim = out.phi(2,1,:); % Angulo del servo o brazo en rad
phi_sim = phi_sim(:);

phi_p = out.phi_p(1,1,:); % Velocidad angular del servo o brazo en rad/s
phi_p = phi_p(:);

r_phi = out.phi_p(2,1,:); % Velocidad angular del servo o brazo en rad/s
r_phi = r_phi(:);

% Guardo los datos en archivo CSV:

% Datos 

%datos = [t,theta, theta_sim, theta_p, theta_p_sim, phi, phi_sim, phi_p,phi_p_sim];
datos = [t,theta, theta_sim, theta_p, theta_p_sim, phi, phi_sim, phi_p,r_phi];

% Convertir la matriz a tabla y asignar nombres a las columnas
tabla = array2table(datos, 'VariableNames', {'t','theta','theta_sim','theta_p','theta_p_sim', 'phi','phi_sim','phi_p','r_phi'});


% Obtener la hora actual en formato 'HHMMSS'
hora_actual = datestr(now, 'yyyymmdd_HHMMSS');

% Crear el nombre del archivo con la hora del día
nombre_archivo = ['test_controlador_integral_' hora_actual '.csv'];

% Exportar la tabla a un archivo CSV con encabezados de columnas
writetable(tabla, nombre_archivo);

disp(['Archivo guardado como: ' nombre_archivo]);


