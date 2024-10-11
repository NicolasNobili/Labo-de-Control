close all;
s = tf('s');

% Configuración del Bode
my_bode_options = bodeoptions;
my_bode_options.PhaseMatching = 'on';
my_bode_options.PhaseMatchingFreq = 1;
my_bode_options.PhaseMatchingValue = -180;
my_bode_options.Grid = 'on';

% La planta a controlar con un PID 
P = (-0.099863 * s) / ((s+10.14)*(s-10.14));

% Controlador PID para controlar la planta
kp = db2mag(50);
ki = kp*10.14;
kd = 10.14;

% Pruebo un PI que funcione
C_PI = -kp*(s+ki/kp)/s;
figure();
bode(minreal(C*P), my_bode_options)

% Pruebo un PID agregando un valor de Kd que no me lo rompa
C = -kp*(s+ki/kp)/s - kd *s/(s+1000); 
figure();
bode(minreal(C*P), my_bode_options)

